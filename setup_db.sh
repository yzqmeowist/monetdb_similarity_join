# #!/bin/bash
# set -e

# ROOT_DIR=$(pwd)
# INSTALL_DIR="$ROOT_DIR/install"
# BIN_DIR="$INSTALL_DIR/bin"
# LIB_DIR="$INSTALL_DIR/lib"
# CMD_MONETDBD="$BIN_DIR/monetdbd"
# CMD_MONETDB="$BIN_DIR/monetdb"
# CMD_MCLIENT="$BIN_DIR/mclient"

# DB_FARM_PATH="$ROOT_DIR/monetdb_farm"
# DB_NAME="test_db"

# AUTH_FILE="$ROOT_DIR/.monetdb_auth"

# if [ ! -f "$CMD_MONETDBD" ]; then
#     echo "Error: $CMD_MONETDBD not found, please run build.sh first..."
#     exit 1
# fi

# export LD_LIBRARY_PATH="$LIB_DIR:$LD_LIBRARY_PATH"
# export DYLD_LIBRARY_PATH="$LIB_DIR:$DYLD_LIBRARY_PATH"

# cat > "$AUTH_FILE" <<EOF
# user=monetdb
# password=monetdb
# language=sql
# save_history=true
# EOF

# export DOTMONETDBFILE="$AUTH_FILE"

# echo "Cleaning old daemons..."
# if [ -d "$DB_FARM_PATH" ]; then
#     "$CMD_MONETDBD" stop "$DB_FARM_PATH" || true
#     sleep 1
# fi

# echo "Starting MonetDB daemon process..."
# rm -rf "$DB_FARM_PATH"
# if [ ! -d "$DB_FARM_PATH" ]; then
#     "$CMD_MONETDBD" create "$DB_FARM_PATH" || { echo "failed to create farm"; exit 1; }
# fi

# "$CMD_MONETDBD" start "$DB_FARM_PATH"

# echo "Initializing database..."

# if "$CMD_MONETDB" status | grep -q "$DB_NAME"; then
#     echo "   '$DB_NAME' exists"
# else
#     echo "   creating '$DB_NAME'..."
#     "$CMD_MONETDB" create "$DB_NAME" || { echo "failed to create"; exit 1; }
# fi

# "$CMD_MONETDB" release "$DB_NAME"
# sleep 2

# echo "Initializing data..."

# "$CMD_MCLIENT" -d "$DB_NAME" <<EOF
# DROP TABLE IF EXISTS uw;
# DROP TABLE IF EXISTS mw;

# CREATE TABLE uw (U VARCHAR(10), F VARCHAR(50));
# CREATE TABLE mw (M VARCHAR(10), G VARCHAR(50));

# CREATE TABLE uw2 (U VARCHAR(10), F VARCHAR(100));
# CREATE TABLE mw2 (M VARCHAR(10), G VARCHAR(100));

# INSERT INTO uw VALUES ('u2', '[1.0, -0.5]'), ('u3', '[2.0, -1.0]'), 
#                       ('u4', '[4.2, 1.3]'),  ('u5', '[1.0, -0.7]');

# INSERT INTO mw VALUES ('m1', '[1.9, -1.5]'), ('m2', '[1.1, -2.0]'), 
#                       ('m4', '[2.1, -0.6]');

# INSERT INTO uw2 VALUES 
#     ('u21', '[1.0, 0.5, 0.3, 0.1, -0.2, -0.4, 0.6, 0.7, 0.2, -0.1, 0.3]'),
#     ('u22', '[0.8, 0.3, 0.4, 0.2, -0.3, -0.5, 0.7, 0.8, 0.1, -0.2, 0.2]'),
#     ('u23', '[0.9, 0.4, 0.2, 0.3, -0.1, -0.3, 0.5, 0.6, 0.3, -0.3, 0.4]'),
#     ('u24', '[1.1, 0.6, 0.3, 0.0, -0.4, -0.6, 0.8, 0.9, 0.0, -0.1, 0.1]'),
#     ('u25', '[0.7, 0.2, 0.5, 0.4, -0.5, -0.7, 0.4, 0.5, 0.4, -0.4, 0.5]'),
#     ('u26', '[1.2, 0.7, 0.1, -0.1, -0.8, -0.9, 0.9, 1.0, -0.1, 0.0, 0.0]'),
#     ('u27', '[0.6, 0.1, 0.6, 0.5, -0.6, -0.8, 0.3, 0.4, 0.5, -0.5, 0.6]'),
#     ('u28', '[1.3, 0.8, 0.0, -0.2, -0.9, -1.0, 1.0, 1.1, -0.2, 0.1, -0.1]'),
#     ('u29', '[0.5, 0.0, 0.7, 0.6, -0.7, -0.9, 0.2, 0.3, 0.6, -0.6, 0.7]'),
#     ('u210', '[1.0, 0.5, 0.3, 0.1, -0.2, -0.4, 0.6, 0.7, 0.2, -0.1, 0.3]'),
#     ('u211', '[0.8, 0.3, 0.4, 0.2, -0.3, -0.5, 0.7, 0.8, 0.1, -0.2, 0.2]'),
#     ('u212', '[0.9, 0.4, 0.2, 0.3, -0.1, -0.3, 0.5, 0.6, 0.3, -0.3, 0.4]'),
#     ('u213', '[1.1, 0.6, 0.3, 0.0, -0.4, -0.6, 0.8, 0.9, 0.0, -0.1, 0.1]'),
#     ('u214', '[0.7, 0.2, 0.5, 0.4, -0.5, -0.7, 0.4, 0.5, 0.4, -0.4, 0.5]'),
#     ('u215', '[1.2, 0.7, 0.1, -0.1, -0.8, -0.9, 0.9, 1.0, -0.1, 0.0, 0.0]'),
#     ('u216', '[0.6, 0.1, 0.6, 0.5, -0.6, -0.8, 0.3, 0.4, 0.5, -0.5, 0.6]'),
#     ('u217', '[1.3, 0.8, 0.0, -0.2, -0.9, -1.0, 1.0, 1.1, -0.2, 0.1, -0.1]'),
#     ('u218', '[0.5, 0.0, 0.7, 0.6, -0.7, -0.9, 0.2, 0.3, 0.6, -0.6, 0.7]'),
#     ('u219', '[1.4, 0.9, -0.1, -0.3, -1.0, -1.1, 1.1, 1.2, -0.3, 0.2, -0.2]');


# INSERT INTO mw2 VALUES 
#     ('m21', '[0.9, 0.4, 0.2, 0.3, -0.1, -0.3, 0.5, 0.6, 0.3, -0.3, 0.4]'),
#     ('m22', '[1.1, 0.6, 0.3, 0.0, -0.4, -0.6, 0.8, 0.9, 0.0, -0.1, 0.1]'),
#     ('m23', '[0.7, 0.2, 0.5, 0.4, -0.5, -0.7, 0.4, 0.5, 0.4, -0.4, 0.5]'),
#     ('m24', '[1.2, 0.7, 0.1, -0.1, -0.8, -0.9, 0.9, 1.0, -0.1, 0.0, 0.0]'),
#     ('m25', '[0.6, 0.1, 0.6, 0.5, -0.6, -0.8, 0.3, 0.4, 0.5, -0.5, 0.6]'),
#     ('m26', '[1.3, 0.8, 0.0, -0.2, -0.9, -1.0, 1.0, 1.1, -0.2, 0.1, -0.1]'),
#     ('m27', '[0.5, 0.0, 0.7, 0.6, -0.7, -0.9, 0.2, 0.3, 0.6, -0.6, 0.7]'),
#     ('m28', '[1.4, 0.9, -0.1, -0.3, -1.0, -1.1, 1.1, 1.2, -0.3, 0.2, -0.2]'),
#     ('m29', '[1.0, 0.5, 0.3, 0.1, -0.2, -0.4, 0.6, 0.7, 0.2, -0.1, 0.3]'),
#     ('m210', '[0.9, 0.4, 0.2, 0.3, -0.1, -0.3, 0.5, 0.6, 0.3, -0.3, 0.4]'),
#     ('m211', '[1.1, 0.6, 0.3, 0.0, -0.4, -0.6, 0.8, 0.9, 0.0, -0.1, 0.1]'),
#     ('m212', '[0.7, 0.2, 0.5, 0.4, -0.5, -0.7, 0.4, 0.5, 0.4, -0.4, 0.5]'),
#     ('m213', '[1.2, 0.7, 0.1, -0.1, -0.8, -0.9, 0.9, 1.0, -0.1, 0.0, 0.0]'),
#     ('m214', '[0.6, 0.1, 0.6, 0.5, -0.6, -0.8, 0.3, 0.4, 0.5, -0.5, 0.6]'),
#     ('m215', '[1.3, 0.8, 0.0, -0.2, -0.9, -1.0, 1.0, 1.1, -0.2, 0.1, -0.1]'),
#     ('m216', '[0.5, 0.0, 0.7, 0.6, -0.7, -0.9, 0.2, 0.3, 0.6, -0.6, 0.7]'),
#     ('m217', '[1.4, 0.9, -0.1, -0.3, -1.0, -1.1, 1.1, 1.2, -0.3, 0.2, -0.2]'),
#     ('m218', '[1.0, 0.5, 0.3, 0.1, -0.2, -0.4, 0.6, 0.7, 0.2, -0.1, 0.3]'),
#     ('m219', '[0.8, 0.3, 0.4, 0.2, -0.3, -0.5, 0.7, 0.8, 0.1, -0.2, 0.2]');

# SELECT * FROM uw;`
# SELECT * FROM mw;
# SELECT M FROM uw, mw WHERE U='u2' ORDER BY dot(F,G) DESC LIMIT 5;
# SELECT U,M FROM uw, mw WHERE dot(F,G) > 3;
# SELECT * FROM uw2;
# SELECT * FROM mw2;
# SELECT M FROM uw2, mw2 WHERE U='u21' ORDER BY dot(F,G) DESC LIMIT 8;
# SELECT M FROM uw2, mw2 WHERE U='u21' ORDER BY cdot(F,G) DESC LIMIT 8;


# EOF

# echo "Done!"
# echo "Please execute the following command to test your changes:"
# echo "    export DOTMONETDBFILE=\"$AUTH_FILE\""
# echo "    export PATH=\"$BIN_DIR:\$PATH\""
# echo "    mclient -d $DB_NAME"
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

CREATE TABLE uw (U VARCHAR(10), F VARCHAR(2000));
CREATE TABLE mw (M VARCHAR(10), G VARCHAR(2000));

COPY INTO uw FROM '$ROOT_DIR/ml-latest-small/uw.csv' USING DELIMITERS ',', '\n', '"';
COPY INTO mw FROM '$ROOT_DIR/ml-latest-small/mw.csv' USING DELIMITERS ',', '\n', '"';

SELECT M FROM uw, mw WHERE U='u2' ORDER BY dot(F,G) DESC LIMIT 20;
SELECT M FROM uw, mw WHERE U='u2' ORDER BY cdot(F,G) DESC LIMIT 20;
# SELECT U,M FROM uw, mw WHERE dot(F,G) > 3;

EOF

echo "Done!"
echo "Please execute the following command to test your changes:"
echo "    export DOTMONETDBFILE=\"$AUTH_FILE\""
echo "    export PATH=\"$BIN_DIR:\$PATH\""
echo "    mclient -d $DB_NAME"

# INSERT INTO uw VALUES ('u2', '[1.0, -0.5]'), ('u3', '[2.0, -1.0]'), 
#                       ('u4', '[4.2, 1.3]'),  ('u5', '[1.0, -0.7]');

# INSERT INTO mw VALUES ('m1', '[1.9, -1.5]'), ('m2', '[1.1, -2.0]'), 
#                       ('m4', '[2.1, -0.6]');