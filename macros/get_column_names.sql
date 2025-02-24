{% macro get_column_names(table_name) %}
    {%- set query -%}
        SELECT DISTINCT column_name
        FROM information_schema.columns
        WHERE table_name = UPPER('{{ table_name }}')
    {%- endset -%}

    {% if execute %}
        {%- set results = run_query(query) -%}
        {%- set column_names = results.columns[0].values() if results and results.columns else [] -%}

        {{ return(column_names) }}
    {% endif %}
{% endmacro %}
