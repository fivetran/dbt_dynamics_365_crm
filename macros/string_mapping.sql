{% macro string_mapping(table_name) -%}
    {{ return(adapter.dispatch('string_mapping', 'dynamics_365_crm')(table_name)) }}
{% endmacro %}

{% macro default__string_mapping(table_name) %}
    {{ config(enabled=var('dynamics_365_crm_using_' ~ table_name, True)) }}
    {%- set columns = adapter.get_columns_in_relation(source('dynamics_365_crm', table_name)) -%}
    {# Retrieves the attribute names available for the subject table #}
    {%- set attributes = dbt_utils.get_column_values(
        table=source('dynamics_365_crm', 'stringmap'),
        where="lower(objecttypecode) = '" ~ table_name ~ "'",
        column='attributename'
        ) -%}

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

    with unpivoted as (
        -- Converting the subject table from wide to long format
        {{ dbt_utils.unpivot(
            relation=source('dynamics_365_crm', table_name),
            cast_to=dbt.type_int(),
            exclude=non_pivot_fields,
            field_name='fieldname',
            value_name='fieldvalue'
        ) }}

    {%- set stringmap_columns = adapter.get_columns_in_relation(source('dynamics_365_crm', 'stringmap')) | map(attribute='name') | list -%}
    {%- set attribute_column = 'renamed_attributename' if 'renamed_attributename' in stringmap_columns else 'attributename' -%}
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
            {% for field in non_pivot_fields %}
                {{ field }},
            {% endfor %}
            {% for field in fields %}
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue else null end) as {{ field }},
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue_name else null end) as {{ field }}_label{{ ',' if not loop.last }}
            {% endfor %}
        from joined
        {{ dbt_utils.group_by(non_pivot_fields|length) }}

    )
    select *
    from repivoted

{% endmacro %}