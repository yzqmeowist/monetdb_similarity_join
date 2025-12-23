#!/bin/bash
set -e

ROOT_DIR=$(pwd)
INSTALL_DIR="$ROOT_DIR/install"
BIN_DIR="$INSTALL_DIR/bin"
LIB_DIR="$INSTALL_DIR/lib"
CMD_MONETDBD="$BIN_DIR/monetdbd"
CMD_MONETDB="$BIN_DIR/monetdb"
CMD_MCLIENT="$BIN_DIR/mclient"

DB_FARM_PATH="$ROOT_DIR/monetdb_farm"
DB_NAME="test_db"

AUTH_FILE="$ROOT_DIR/.monetdb_auth"

if [ ! -f "$CMD_MONETDBD" ]; then
    echo "Error: $CMD_MONETDBD not found, please run build.sh first..."
    exit 1
fi

export LD_LIBRARY_PATH="$LIB_DIR:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$LIB_DIR:$DYLD_LIBRARY_PATH"

cat > "$AUTH_FILE" <<EOF
user=monetdb
password=monetdb
language=sql
save_history=true
EOF

export DOTMONETDBFILE="$AUTH_FILE"

echo "Cleaning old daemons..."
if [ -d "$DB_FARM_PATH" ]; then
    "$CMD_MONETDBD" stop "$DB_FARM_PATH" || true
    sleep 1
fi

echo "Starting MonetDB daemon process..."
rm -rf "$DB_FARM_PATH"
if [ ! -d "$DB_FARM_PATH" ]; then
    "$CMD_MONETDBD" create "$DB_FARM_PATH" || { echo "failed to create farm"; exit 1; }
fi

"$CMD_MONETDBD" start "$DB_FARM_PATH"

echo "Initializing database..."

if "$CMD_MONETDB" status | grep -q "$DB_NAME"; then
    echo "   '$DB_NAME' exists"
else
    echo "   creating '$DB_NAME'..."
    "$CMD_MONETDB" create "$DB_NAME" || { echo "failed to create"; exit 1; }
fi

"$CMD_MONETDB" release "$DB_NAME"
sleep 2

echo "Initializing data..."

"$CMD_MCLIENT" -d "$DB_NAME" <<EOF
DROP TABLE IF EXISTS uw;
DROP TABLE IF EXISTS mw;

CREATE TABLE uw (U VARCHAR(10), F VARCHAR(50));
CREATE TABLE mw (M VARCHAR(10), G VARCHAR(50));

INSERT INTO uw VALUES ('u2', '[1.0, -0.5]'), ('u3', '[2.0, -1.0]'), 
                      ('u4', '[4.2, 1.3]'),  ('u5', '[1.0, -0.7]');

INSERT INTO mw VALUES ('m1', '[1.9, -1.5]'), ('m2', '[1.1, -2.0]'), 
                      ('m4', '[2.1, -0.6]');

SELECT 'Status', 'Database Ready' AS Info;
SELECT 'Users Loaded', COUNT(*) FROM uw;
SELECT 'Movies Loaded', COUNT(*) FROM mw;
EOF

echo "Done!"
echo "Please execute the following command to test your changes:"
echo "    export DOTMONETDBFILE=\"$AUTH_FILE\""
echo "    export PATH=\"$BIN_DIR:\$PATH\""
echo "    mclient -d $DB_NAME"