#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    create extension plpython3u;   
    create function get_python_version()
      returns text
      as \$\$
        import sys
        
        python_version = sys.version
        
        return python_version
      \$\$ language plpython3u;

EOSQL
