{% macro string_mapping(table_name) -%}
    {{ return(adapter.dispatch('string_mapping', 'dynamics_365_crm')(table_name)) }}
{% endmacro %}

{% macro default__string_mapping(table_name) %}
    {{ config(enabled=var('dynamics_365_crm_using_' ~ table_name, True)) }}
    {%- set columns = adapter.get_columns_in_relation(source('dynamics_365_crm', table_name)) -%}
    {%- set attributes = dbt_utils.get_column_values(
        table=source('dynamics_365_crm', 'stringmap'),
        where="lower(objecttypecode) = '" ~ table_name ~ "'",
        column='attributename') -%}

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

        select
            stringmapid,
            cast(attributevalue as {{ dbt.type_string()}}) as attributevalue,
            cast(attributename as {{ dbt.type_string()}}) as attributename,
            cast(objecttypecode as {{ dbt.type_string()}}) as objecttypecode,
            cast(value as {{ dbt.type_string()}}) as stringmap_value
        from {{ source('dynamics_365_crm', 'stringmap')}}
        where lower(objecttypecode) = {{ "'" ~ table_name ~ "'" }}
        and not coalesce(_fivetran_deleted, false)

    ), joined as (
        select
            unpivoted.*,
            stringmaps.stringmap_value as fieldvalue_name
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