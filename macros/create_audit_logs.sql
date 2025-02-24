{% macro create_audit_log() %}
    {% set sql %}
        create table if not exists {{ target.database }}.{{ target.schema }}.audit_logs (
            audit_id int autoincrement primary key,
            model_name string,
            start_time timestamp,
            end_time timestamp,
            execution_time string as (
                lpad(floor(datediff(millisecond, start_time, end_time) / 60000), 2, '0') || ':' ||
                lpad(floor((datediff(millisecond, start_time, end_time) % 60000) / 1000), 2, '0') || ':' ||
                lpad(datediff(millisecond, start_time, end_time) % 1000, 3, '0')
            )
        );
    {% endset %}

    {% if execute %}
        {{ run_query(sql) }}
    {% endif %}
{% endmacro %}