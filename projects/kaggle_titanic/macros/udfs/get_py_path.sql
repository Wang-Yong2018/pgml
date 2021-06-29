{% macro get_py_path() %}
    create
    or replace function {{target.schema }}.get_py_path() 
    returns text
    as $$ 
    import sys
    import json

    py_path_str = json.dumps(sys.path)
    return py_path_str


    $$ language 'plpython3u' volatile COST 5000; 
{% endmacro %}