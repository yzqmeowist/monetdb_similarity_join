/*
 * SPDX-License-Identifier: MPL-2.0
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2024, 2025 MonetDB Foundation;
 * Copyright August 2008 - 2023 MonetDB B.V.;
 * Copyright 1997 - July 2008 CWI.
 */

#include "monetdb_config.h"
#include "rel_pca.h"
#include "sql_mvc.h"
#include "sql_symbol.h"
#include "sql_relation.h"
#include "sql_catalog.h"
#include "sql_atom.h"
#include "sql_list.h"
#include "rel_rel.h"
#include "rel_exp.h"     /* 这个必须包含 */

sql_rel *
rel_pcatrain(sql_query *query, symbol *s)
{
    mvc *sql = query->sql;
    dlist *l = s->data.lval;
    dnode *n = l->h;
    
    fprintf(stderr, "\n[DEBUG-SEMANTIC] 1. rel_pcatrain called\n");
    
    /* 解析 AST 参数 */
    dlist *tbl_list = n->data.lval;
    char *schema_name = NULL;
    char *tbl_name = NULL;
    
    dnode *tn = tbl_list->h;
    if (dlist_length(tbl_list) == 1) {
        tbl_name = tn->data.sval;
    } else if (dlist_length(tbl_list) == 2) {
        schema_name = tn->data.sval;
        tn = tn->next;
        tbl_name = tn->data.sval;
    }
    
    n = n->next;
    int target_dim = n->data.i_val;
    
    n = n->next;
    char *model_name = n->data.sval;

    fprintf(stderr, "[DEBUG-SEMANTIC] 2. Parsed args: src='%s', dst='%s', dim=%d\n", tbl_name, model_name, target_dim);

    /* 检查和绑定表信息 */
    sql_schema *s_src = schema_name ? mvc_bind_schema(sql, schema_name) : cur_schema(sql);
    if (schema_name && !s_src) 
        return sql_error(sql, 02, SQLSTATE(3F000) "SCHEMA '%s' does not exist", schema_name);
        
    sql_table *src_t = mvc_bind_table(sql, s_src, tbl_name);
    sql_table *dst_t = mvc_bind_table(sql, cur_schema(sql), model_name);

    if (!src_t) return sql_error(sql, 02, SQLSTATE(42S02) "Source TABLE '%s' does not exist", tbl_name);
    if (!dst_t) return sql_error(sql, 02, SQLSTATE(42S02) "Target TABLE '%s' does not exist", model_name);
    if (target_dim < 2) return sql_error(sql, 02, SQLSTATE(42000) "Target dimension must be >= 2");

    fprintf(stderr, "[DEBUG-SEMANTIC] 3. Tables bound. src_t=%p, dst_t=%p\n", (void*)src_t, (void*)dst_t);

    /* 类型检查 */
    sql_column *dst_col = ol_first_node(dst_t->columns)->data;
    sql_subtype *model_type = sql_bind_localtype("str"); 
    
    if (subtype_cmp(&dst_col->type, model_type) != 0) {
        return sql_error(sql, 02, SQLSTATE(42000) 
            "Type Mismatch: Target column '%s' must be of type STRING/VARCHAR to store PCA model.", 
            dst_col->base.name);
    }

    fprintf(stderr, "[DEBUG-SEMANTIC] 4. Type check passed. Building logic tree...\n");

    /* 构建纯正的关系代数树 */
    sql_rel *ret = rel_create(sql->sa);
    ret->op = op_pcatrain; 
    
    ret->l = rel_basetable(sql, src_t, src_t->base.name); 
    ret->r = rel_basetable(sql, dst_t, dst_t->base.name); 
    ret->flag = target_dim;
    sql->type = Q_UPDATE; 

    fprintf(stderr, "[DEBUG-SEMANTIC] 5. op_pcatrain logical node built successfully! Returning %p\n", (void*)ret);
    return ret;
}