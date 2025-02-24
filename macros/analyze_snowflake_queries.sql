{% macro analyze_snowflake_queries(days_back=7, limit=20) %}
    {% set query %}
        SELECT 
            query_id, 
            warehouse_name,
            user_name,
            execution_status,
            start_time,
            total_elapsed_time / 1000 AS total_execution_time_seconds,
            bytes_scanned / POWER(1024, 3) AS bytes_scanned_gb,
            partitions_scanned,
            partitions_total,
            CASE 
                WHEN partitions_total > 0 THEN ROUND((partitions_scanned::FLOAT / partitions_total) * 100, 2)
                ELSE NULL 
            END AS partition_scan_percentage,
            compilation_time / 1000 AS compilation_time_seconds,
            execution_time / 1000 AS execution_time_seconds,
            (queued_provisioning_time + queued_repair_time + queued_overload_time) / 1000 AS total_queue_time_seconds,
            bytes_spilled_to_local_storage / POWER(1024, 3) AS spillage_to_local_gb,
            bytes_spilled_to_remote_storage / POWER(1024, 3) AS spillage_to_remote_gb,
            credits_used_cloud_services AS credits_used,
            database_name,
            schema_name,
            query_text
        FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
        WHERE start_time >= DATEADD(DAY, -{{ days_back }}, CURRENT_TIMESTAMP())
        and database_name = '{{ target.database }}'
        ORDER BY total_execution_time_seconds DESC
        LIMIT {{ limit }}
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute and results|length > 0 %}
        {% for row in results %}
            {% set credits_used_formatted = "%.8f" % row['CREDITS_USED'] %}
            {{ print("✅ Query Execution Log") }}
            {{ print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━") }}
            {{ print("🆔 Query ID       : " ~ row['QUERY_ID']) }}
            {{ print("📌 Status         : " ~ row['EXECUTION_STATUS']) }}
            {{ print("❄️  Credits Used   : " ~ credits_used_formatted ~ " credits") }}
            {{ print("👤 User           : " ~ row['USER_NAME']) }}
            {{ print("🏢 Warehouse      : " ~ row['WAREHOUSE_NAME']) }}
            {{ print("🗄️  Database       : " ~ row['DATABASE_NAME']) }}
            {{ print("📂 Schema        : " ~ row['SCHEMA_NAME']) }}
            {{ print("⏳ Start Time     : " ~ row['START_TIME']) }}
            {{ print("⏲️  Total Execution Time: " ~ row['TOTAL_EXECUTION_TIME_SECONDS'] ~ " sec") }}
            {{ print("📊 Bytes Scanned  : " ~ row['BYTES_SCANNED_GB'] ~ " GB") }}
            {{ print("🗂️  Partitions Scanned: " ~ row['PARTITIONS_SCANNED']) }}
            {{ print("📈 Partition Scan %: " ~ row['PARTITION_SCAN_PERCENTAGE'] ~ " %") }}
            {{ print("⚡ Compilation Time: " ~ row['COMPILATION_TIME_SECONDS'] ~ " sec") }}
            {{ print("⏱️  Execution Time: " ~ row['EXECUTION_TIME_SECONDS'] ~ " sec") }}
            {{ print("⏳ Total Queue Time: " ~ row['TOTAL_QUEUE_TIME_SECONDS'] ~ " sec") }}
            {{ print("🗄️  Spillage to Local : " ~ row['SPILLAGE_TO_LOCAL_GB'] ~ " GB") }}
            {{ print("🗄️  Spillage to Remote: " ~ row['SPILLAGE_TO_REMOTE_GB'] ~ " GB") }}
            {{ print("📝 Query Text     : " ~ row['QUERY_TEXT']) }}
            {{ print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━") }}
        {% endfor %}
    {% endif %}

    {{ return(results) }}
{% endmacro %}