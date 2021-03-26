#!/bin/sh

echo 'Creating a user for the Postgres database. Choose a password.'
createuser --pwprompt synapse_user

# See https://github.com/matrix-org/synapse/blob/develop/docs/postgres.md

echo 'Creating the Postgres database named `synapse` owned by `synapse_user`'
psql -c "CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse_user;"

