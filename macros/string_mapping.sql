{% macro string_mapping(table_name) -%}
    {{ return(adapter.dispatch('string_mapping', 'dynamics_365_crm')(table_name)) }}
{% endmacro %}

{% macro default__string_mapping(table_name) %}
    {{ config(enabled=var('dynamics_365_crm_using_' ~ table_name, True)) }}
    {%- set columns = adapter.get_columns_in_relation(source('dynamics_365_crm', table_name)) -%}
    {%- set attributes = dbt_utils.get_column_values(table=ref('stg_dynamics_365_crm__stringmap'), column='attributename') -%}

    {%- set fields = [] -%}
    {%- set non_pivot_fields = [] -%}
    {%- for col in columns -%}
        {%- if col.name | lower in attributes | map('lower') -%}
            {%- do fields.append(col.name) -%}
        {%- else -%}
            {%- do non_pivot_fields.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}

    with unpivoted as (
        {{ dbt_utils.unpivot(
            relation=source('dynamics_365_crm', table_name),
            cast_to=dbt.type_string(),
            exclude=non_pivot_fields,
            field_name='fieldname',
            value_name='fieldvalue'
        ) }}

    ), stringmaps as (
        select *
        from {{ ref('stg_dynamics_365_crm__stringmap') }}
        where lower(objecttypecode) = {{ "'" ~ table_name ~ "'" }}

    ), joined as (
        select
            unpivoted.*,
            coalesce(stringmaps.stringmap_value, unpivoted.fieldvalue) as fieldvalue_name -- coalesce in case there isn't a match
        from unpivoted
        left join stringmaps
        on lower(unpivoted.fieldname) = lower(stringmaps.attributename)
        and lower(unpivoted.fieldvalue) = lower(stringmaps.attributevalue)

    ), repivoted as (
        select
            {% for field in non_pivot_fields %}
                {{ field }},
            {% endfor %}
            {% for field in fields %}
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue else null end) as {{ field }},
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue_name else null end) as {{ field }}_name{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        {{ dbt_utils.group_by(non_pivot_fields|length) }}

    )
    select *
    from repivoted

{% endmacro %}