{% macro audit_pre_hook(model_name) %}
  {% if target.name == 'dev' %}

    {% set pre_insert %}
      insert into {{ target.database }}.{{ target.schema }}.audit_logs 
      (model_name, start_time) 
      select 
        '{{ model_name }}',
        current_timestamp;
    {% endset %}

    {% if execute %}
        {% set result = run_query(pre_insert) %}
        {% do log('✅ audit log entry created for: ' ~ model_name ~ ' with status: ' ~ result.status, info=true) %}
    {% endif %}

  {% endif %}
{% endmacro %}

{% macro audit_post_hook(model_name) %}
  {% if target.name == 'dev' %}

    {{ log('🚀 updating audit log for: ' ~ model_name, info=true) }}

    {% set update_query %}
      update {{ target.database }}.{{ target.schema }}.audit_logs 
      set end_time = current_timestamp 
      where model_name = '{{ model_name }}'
      and start_time = (select max(start_time) from {{ target.database }}.{{ target.schema }}.audit_logs where model_name = '{{ model_name }}');
    {% endset %}

    {% if execute %}
        {% set result = run_query(update_query) %}
        {% do log('✅ audit log updated for: ' ~ model_name ~ ' with status: ' ~ result.status, info=true) %}
    {% else %}
        {{ log('⚠ skipping execution in parsing mode', info=true) }}
    {% endif %}

  {% endif %}
{% endmacro %}

{% macro print_audit_logs(model_name) %}

  {% if target.name == 'dev' %}

    {{ log("🚀 fetching latest audit log for model: " ~ model_name, info=true) }}

    {% set fetch_query %}
        select model_name, start_time, end_time, 
               timestampdiff(millisecond, start_time, end_time) as execution_time_ms
        from {{ target.database }}.{{ target.schema }}.audit_logs
        where model_name = '{{ model_name }}'
        order by start_time desc
        limit 1;
    {% endset %}

    {% if execute %}
        {% set result_table = run_query(fetch_query) %}

        {% if result_table and result_table.rows | length > 0 %}
            {% set row = result_table.rows[0] %}
            {% set execution_time = row[3] %}
            {% set formatted_time = (execution_time // 60000) ~ ":" ~ ((execution_time % 60000) // 1000) ~ ":" ~ (execution_time % 1000) %}

            {{ log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", info=true) }}
            {{ log("✅ audit log entry", info=true) }}
            {{ log("🆔 model name      : " ~ row[0], info=true) }}
            {{ log("⏳ start time      : " ~ row[1], info=true) }}
            {{ log("⏱️  end time        : " ~ row[2], info=true) }}
            {{ log("⏲️  execution time  : " ~ formatted_time, info=true) }}
            {{ log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", info=true) }}
        {% else %}
            {{ log("⚠ no audit log found for model: " ~ model_name, info=true) }}
        {% endif %}
    {% else %}
        {{ log("⚠ skipping execution in parsing mode", info=true) }}
    {% endif %}

  {% else %}
    {{ log("🚫 Skipping execution: This macro runs only in 'dev' environment.", info=true) }}
  {% endif %}

{% endmacro %}
