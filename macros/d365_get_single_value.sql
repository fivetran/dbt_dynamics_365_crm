{% macro get_single_value(query, default=none) %}
    {{ return(adapter.dispatch('get_single_value', 'dynamics_365_crm')(query, default)) }}
{% endmacro %}

{% macro default__get_single_value(query, default) %}

{# This macro returns the (0, 0) record in a query, i.e. the first row of the first column #}

    {%- call statement('get_query_result', fetch_result=True, auto_begin=false) -%}

        {{ query }}

    {%- endcall -%}

    {%- if execute -%}

        {% set r = load_result('get_query_result').table.columns[0].values() %}
        {% if r | length == 0 %}
            {% set sql_result = default %}
        {% else %}
            {% set sql_result = r[0] %}
        {% endif %}
        
    {%- else -%}
    
        {% set sql_result = default %}
    
    {%- endif -%}

    {% do return(sql_result) %}

{% endmacro %}