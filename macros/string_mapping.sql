{% macro string_mapping(table_name, primary_key) -%}
    {{ return(adapter.dispatch('string_mapping', 'dynamics_365_crm')(table_name, primary_key)) }}
{% endmacro %}

{% macro default__string_mapping(table_name, primary_key) %}
    {{ config(enabled=var('dynamics_365_crm_using_' ~ table_name, True)) }}
    {%- set columns = adapter.get_columns_in_relation(source('dynamics_365_crm', table_name)) -%}
    {# Retrieves the attribute names available for the subject table #}
    {%- set stringmap_columns = adapter.get_columns_in_relation(source('dynamics_365_crm', 'stringmap')) | map(attribute='name') | map('lower') | list -%}
    {%- set attribute_column = 'renamed_attributename' if 'renamed_attributename' in stringmap_columns else 'attributename' -%}
    {%- set attributes = dbt_utils.get_column_values(
        table=source('dynamics_365_crm', 'stringmap'),
        where="lower(objecttypecode) = '" ~ table_name ~ "'",
        column=attribute_column) -%}

    {# Create two lists: 1. fields for mapping 2. all the remaining fields #}
    {%- set fields = [] -%}
    {%- set non_pivot_fields = [] -%}
    {%- for col in columns -%}
        {%- if col.name | lower in attributes | map('lower') and not col.is_string() -%}
            {%- do fields.append(col.name) -%}
        {%- else -%}
            {%- do non_pivot_fields.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}

    with base as(
        select *
        from {{ source('dynamics_365_crm', table_name) }}
    
    ), unpivoted as (
        {%- for field in fields -%}
        select
            {{ primary_key }},
            cast('{{ field }}' as {{ dbt.type_string() }}) as fieldname,
            cast({{ field }} as {{ dbt.type_int() }}) as fieldvalue
        from base

        {{ 'union all' if not loop.last }}
        {% endfor %}

    ), stringmaps as (
        select
            stringmapid,
            cast(attributevalue as {{ dbt.type_int() }}) as attributevalue,
            cast({{ attribute_column }} as {{ dbt.type_string() }}) as attributename,
            cast(objecttypecode as {{ dbt.type_string() }}) as objecttypecode,
            cast(value as {{ dbt.type_string()}}) as stringmap_value
        from {{ source('dynamics_365_crm', 'stringmap')}}
        where lower(objecttypecode) = {{ "'" ~ table_name ~ "'" }}
        and not coalesce(_fivetran_deleted, false)

    ), joined as (
        -- the long format table can easily be joined with the stringmap table
        select
            unpivoted.*,
            stringmaps.stringmap_value as fieldvalue_name
        from unpivoted
        left join stringmaps
        on lower(unpivoted.fieldname) = lower(stringmaps.attributename)
        and unpivoted.fieldvalue = stringmaps.attributevalue

    ), repivoted as (
        -- convert back to wide format, now with the human readable columns
        select
            {% for non_pivot_field in non_pivot_fields -%}
                base.{{ non_pivot_field }},
            {% endfor %}
            {% for field in fields -%}
                max(case when lower(joined.fieldname) = lower('{{ field }}') then joined.fieldvalue else null end) as {{ field }},
                max(case when lower(joined.fieldname) = lower('{{ field }}') then joined.fieldvalue_name else null end) as {{ field }}_label{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        left join base
            on joined.{{ primary_key }} = base.{{ primary_key }}
        {{ dbt_utils.group_by(non_pivot_fields|length) }}
    )

    select *
    from repivoted
{% endmacro %}