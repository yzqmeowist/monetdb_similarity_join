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
rel_pca_train(sql_query *query, symbol *s)
{
	mvc *sql = query->sql;
	dlist *l = s->data.lval;
	dnode *n = l->h;
	
	/* 解析参数：pca_train(表名, 维度) INTO 模型名 */
	/* 第一个节点：表名表达式，如 uw */
	symbol *tbl_sym = n->data.sym;
	n = n->next;
	
	/* 第二个节点：目标维度 */
	int target_dim = n->data.i_val;
	n = n->next;
	
	/* 第三个节点：模型名 */
	char *model_name = n->data.sval;
	
	char *tbl_name = NULL;
	
	/* 解析表名表达式 */
	if (tbl_sym->token == SQL_IDENT) {
		tbl_name = tbl_sym->data.sval;        /* 表名：uw */
	} else if (tbl_sym->token == SQL_COLUMN) {
		dlist *cl = tbl_sym->data.lval;
		dnode *cn = cl->h;
		tbl_name = cn->data.sval;              /* 表名：uw */
	}
	
	/* 语义检查 */
	
	/* 1. 检查表是否存在 */
	sql_table *t = NULL;
	if (tbl_name) {
		t = mvc_bind_table(sql, cur_schema(sql), tbl_name);
		if (!t) {
			return sql_error(sql, 02, SQLSTATE(42S02) 
			                 "TABLE '%s' does not exist", tbl_name);
		}
	} else {
		return sql_error(sql, 02, SQLSTATE(42000) 
		                 "Table name required for PCA training");
	}
	
	/* 2. 检查目标维度是否合法 */
	if (target_dim < 0) {
		return sql_error(sql, 02, SQLSTATE(42000) 
		                 "Target dimension must be non-negative (0 for auto-select)");
	}
	if (target_dim == 0) {
		/* 0表示自动选择维度，有效 */
	} else if (target_dim < 2) {
		return sql_error(sql, 02, SQLSTATE(42000) 
		                 "Target dimension must be at least 2 or 0 for auto-select");
	}
	
	/* 3. 检查模型名是否合法 */
	if (!model_name || *model_name == '\0') {
		return sql_error(sql, 02, SQLSTATE(42000) 
		                 "Model name cannot be empty");
	}
	
	/* 创建DDL关系表达式 */
	sql_rel *ret = rel_create(sql->sa);
	ret->op = op_ddl;
	ret->flag = ddl_pca_train;
	
	/* 使用已有的 list 函数创建信息列表 */
	list *info = new_exp_list(sql->sa);  /* 使用 new_exp_list 宏 */
	
	/* 创建表达式来存储信息 - 使用 rel_exp.h 中定义的函数 */
	sql_exp *tbl_exp = exp_atom_str(sql->sa, tbl_name, NULL);  /* NULL 表示使用默认字符串类型 */
	sql_exp *dim_exp = exp_atom_int(sql->sa, target_dim);      /* 这个存在 */
	sql_exp *model_exp = exp_atom_str(sql->sa, model_name, NULL);
	
	/* 添加到列表 - 使用 append 宏 */
	append(info, tbl_exp);
	append(info, dim_exp);
	append(info, model_exp);
	
	/* 存储在 exps 中 */
	ret->exps = info;
	
	return ret;
}