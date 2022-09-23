{%- macro ghost_record_per_datatype(column_name, datatype, ghost_record_type) -%}

{{ return(adapter.dispatch('ghost_record_per_datatype', 'datavault4dbt')(column_name=column_name,
                                                                            datatype=datatype,
                                                                            ghost_record_type=ghost_record_type)) }}

{%- endmacro -%}                                                                            


{%- macro default__ghost_record_per_datatype(column_name, datatype, ghost_record_type) -%}

{%- set beginning_of_all_times = var('datavault4dbt.beginning_of_all_times', '0001-01-01T00-00-01') -%}
{%- set end_of_all_times = var('datavault4dbt.end_of_all_times', '8888-12-31T23-59-59') -%}
{%- set timestamp_format = var('datavault4dbt.timestamp_format', '%Y-%m-%dT%H-%M-%S') -%}

{%- if ghost_record_type == 'unknown' -%}

        {%- if datatype == 'TIMESTAMP' %} {{ datavault4dbt.string_to_timestamp(timestamp_format['default'],beginning_of_all_times['default']) }} as {{ column_name }}
        {%- elif datatype == 'STRING' %} '(unknown)' as {{ column_name }}
        {%- elif datatype == 'INT64' %} CAST('0' as INT64) as {{ column_name }}
        {%- elif datatype == 'FLOAT64' %} CAST('0' as FLOAT64) as {{ column_name }}
        {%- elif datatype == 'BOOLEAN' %} CAST('FALSE' as BOOLEAN) as {{ column_name }}
        {%- else %} CAST(NULL as {{ datatype }}) as {{ column_name }}
        {% endif %}

{%- elif ghost_record_type == 'error' -%}

        {%- if datatype == 'TIMESTAMP' %} {{ datavault4dbt.string_to_timestamp(timestamp_format['default'],end_of_all_times['default']) }} as {{ column_name }}
        {%- elif datatype == 'STRING' %} '(error)' as {{ column_name }}
        {%- elif datatype == 'INT64' %} CAST('-1' as INT64) as {{ column_name }}
        {%- elif datatype == 'FLOAT64' %} CAST('-1' as FLOAT64) as {{ column_name }}
        {%- elif datatype == 'BOOLEAN' %} CAST('FALSE' as BOOLEAN) as {{ column_name }}
        {%- else %} CAST(NULL as {{ datatype }}) as {{ column_name }}
        {% endif %}

{%- else -%}

    {%- if execute -%}
        {{ exceptions.raise_compiler_error("Invalid Ghost Record Type. Accepted are 'unknown' and 'error'.") }}
    {%- endif %}

{%- endif -%}

{%- endmacro -%}

{%- macro exasol__ghost_record_per_datatype(column_name, datatype, ghost_record_type) -%}

{%- set beginning_of_all_times = var('datavault4dbt.beginning_of_all_times', '0001-01-01T00-00-01') -%}
{%- set end_of_all_times = var('datavault4dbt.end_of_all_times', '8888-12-31T23-59-59') -%}
{%- set timestamp_format = var('datavault4dbt.timestamp_format', 'YYYY-mm-ddTHH-MI-SS') -%}

{%- if ghost_record_type == 'unknown' -%}

        {%- if datatype == 'TIMESTAMP' %} {{ datavault4dbt.string_to_timestamp(timestamp_format['default'], beginning_of_all_times['default']) }} as "{{ column_name }}"
        {%- elif datatype == 'VARCHAR' %} '(unknown)' as "{{ column_name }}"
        {%- elif datatype.upper().startswith('VARCHAR') -%}
            
        {%- elif datatype == 'DECIMAL' %} CAST('0' as DECIMAL) as {{ column_name }}
        {%- elif datatype == 'DOUBLE PRECISION' %} CAST('0' as DOUBLE PRECISION) as "{{ column_name }}"
        {%- elif datatype == 'BOOLEAN' %} CAST('FALSE' as BOOLEAN) as "{{ column_name }}"
        {%- else %} CAST(NULL as {{ datatype }}) as "{{ column_name }}"
        {% endif %}

{%- elif ghost_record_type == 'error' -%}

        {%- if datatype == 'TIMESTAMP' %} {{ datavault4dbt.string_to_timestamp(timestamp_format['default'],end_of_all_times['default']) }} as "{{ column_name }}"
        {%- elif datatype == 'VARCHAR' %} '(error)' as "{{ column_name }}"
        {%- elif datatype == 'DECIMAL' %} CAST('-1' as DECIMAL) as "{{ column_name }}"
        {%- elif datatype == 'DOUBLE PRECISION' %} CAST('-1' as DOUBLE PRECISION) as "{{ column_name }}"
        {%- elif datatype == 'BOOLEAN' %} CAST('FALSE' as BOOLEAN) as "{{ column_name }}"
        {%- else %} CAST(NULL as {{ datatype }}) as "{{ column_name }}"
        {% endif %}

{%- else -%}

    {%- if execute -%}
        {{ exceptions.raise_compiler_error("Invalid Ghost Record Type. Accepted are 'unknown' and 'error'.") }}
    {%- endif %}

{%- endif -%}

{%- endmacro -%}

{%- macro snowflake__ghost_record_per_datatype(column_name, datatype, ghost_record_type) -%}

{%- set beginning_of_all_times = var('datavault4dbt.beginning_of_all_times', '0001-01-01T00-00-01') -%}
{%- set end_of_all_times = var('datavault4dbt.end_of_all_times', '8888-12-31T23-59-59') -%}
{%- set timestamp_format = var('datavault4dbt.timestamp_format', '%Y-%m-%dT%H-%M-%S') -%}

{%- if ghost_record_type == 'unknown' -%}
     {%- if datatype in ['TIMESTAMP_NTZ','TIMESTAMP'] %}{{ datavault4dbt.string_to_timestamp(timestamp_format['snowflake'], beginning_of_all_times['snowflake']) }} AS {{ column_name }}
     {% elif datatype in ['STRING','VARCHAR'] %}'(unknown)' AS {{ column_name }}
     {% elif datatype in ['NUMBER','INT','FLOAT','DECIMAL'] %}0 AS {{ column_name }}
     {% elif datatype == 'BOOLEAN' %}CAST('FALSE' AS BOOLEAN) AS {{ column_name }}
     {% else %}NULL AS {{ column_name }}
     {% endif %}
{%- elif ghost_record_type == 'error' -%}
     {%- if datatype in ['TIMESTAMP_NTZ','TIMESTAMP'] %}{{ datavault4dbt.string_to_timestamp(timestamp_format['snowflake'], end_of_all_times['snowflake']) }} AS {{ column_name }}
     {% elif datatype in ['STRING','VARCHAR'] %}'(error)' AS {{ column_name }}
     {% elif datatype in ['NUMBER','INT','FLOAT','DECIMAL'] %}-1 AS {{ column_name }}
     {% elif datatype == 'BOOLEAN' %}CAST('FALSE' AS BOOLEAN) AS {{ column_name }}
     {% else %}NULL AS {{ column_name }}
      {% endif %}
{%- else -%}
    {%- if execute -%}
     {{ exceptions.raise_compiler_error("Invalid Ghost Record Type. Accepted are 'unknown' and 'error'.") }}
    {%- endif %}
{%- endif -%}

{%- endmacro -%}
