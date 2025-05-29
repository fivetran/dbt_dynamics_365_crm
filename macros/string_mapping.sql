{% macro string_mapping(table_name) -%}
    {{ return(adapter.dispatch('string_mapping', 'dynamics_365_crm')(table_name)) }}
{% endmacro %}

{% macro default__string_mapping(table_name) %}
    {{ config(enabled=var('dynamics_365_crm_using_' ~ table_name, True)) }}

    {%- set table_ref = source('dynamics_365_crm', table_name) -%}
    {%- set columns = adapter.get_columns_in_relation(table_ref) -%}
    {%- set available_sources = ('account', 'appointment', 'contact', 'email', 'incident', 'opportunity', 'phonecall', 'systemuser', 'task') -%}

    {%- set attributes = dbt_utils.get_column_values(
        table=source('dynamics_365_crm', 'stringmap'),
        where="lower(objecttypecode) = '" ~ table_name ~ "'",
        column='attributename') -%}

    {%- set stringmap_fields = [] -%}
    {%- set lookup_fields = [] -%}
    {%- set non_pivot_fields = [] -%}

    {%- for col in columns -%}
        {%- if col.name.endswith('_value_microsoft_dynamics_crm_lookuplogicalname') -%}
            {%- do lookup_fields.append(col.name) -%}
        {%- elif col.name | lower in attributes | map('lower') and not col.is_string() -%}
            {%- do stringmap_fields.append(col.name) -%}
        {%- else -%}
            {%- do non_pivot_fields.append(col.name) -%}
        {%- endif -%}
    {%- endfor %}

    -- Handle stringmap fields
    with unpivoted as (
        {{ dbt_utils.unpivot(
            relation=table_ref,
            cast_to=dbt.type_int(),
            exclude=(non_pivot_fields + lookup_fields),
            field_name='fieldname',
            value_name='fieldvalue'
        ) }}
    ),

    stringmaps as (
        select
            cast(attributevalue as {{ dbt.type_int() }}) as attributevalue,
            cast(attributename as {{ dbt.type_string() }}) as attributename,
            cast(objecttypecode as {{ dbt.type_string() }}) as objecttypecode,
            cast(value as {{ dbt.type_string() }}) as stringmap_value
        from {{ source('dynamics_365_crm', 'stringmap') }}
        where lower(objecttypecode) = {{ "'" ~ table_name ~ "'" }}
            and not coalesce(_fivetran_deleted, false)
    ),

    joined_stringmap as (
        select
            unpivoted.*,
            stringmaps.stringmap_value as fieldvalue_name
        from unpivoted
        left join stringmaps
            on lower(unpivoted.fieldname) = lower(stringmaps.attributename)
            and unpivoted.fieldvalue = stringmaps.attributevalue
    ),

    repivoted as (
        select
            {% for field in non_pivot_fields %}
                {{ field }},
            {% endfor %}
            {% for field in stringmap_fields %}
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue else null end) as {{ field }},
                max(case when lower(fieldname) = lower('{{ field }}') then fieldvalue_name else null end) as {{ field }}_label{{ ',' if not loop.last or lookup_fields }}
            {% endfor %}
        from joined_stringmap
        {{ dbt_utils.group_by(non_pivot_fields | length) }}
    ),

-- start lookup logic
{% set sources_from_lookup = {} %}

{% for field in lookup_fields %}
    {% set field_query %}
        select {{ field }}
        from {{ table_ref }}
        where {{ field }} is not null
    {% endset %}

    {% set result = dynamics_365_crm.get_single_value(field_query) %}

    {% set field_base = field | replace('_value_microsoft_dynamics_crm_lookuplogicalname', '') %}
    {% if result in available_sources %}
        {% if sources_from_lookup[result] is defined %}
            {% do sources_from_lookup[result].append(field_base) %}
        {% else %}
            {% do sources_from_lookup.update({ result: [field_base] }) %}
        {% endif %}
    {% endif %}
{% endfor %}

{{ print(sources_from_lookup) if execute }}

joined_friendly_names as (
    select
        repivoted.*
        {% for source_name, columns in sources_from_lookup.items() if source_name in available_sources %}
            {% for column_name in columns %}
                , {{ source_name }}_{{ column_name }}.{{ source_name }}id as {{ column_name }}_friendly
            {% endfor %}
        {% endfor %}
    from repivoted

    {% for source_name, columns in sources_from_lookup.items() if source_name in available_sources %}
        {% for column_name in columns %}
            left join {{ source('dynamics_365_crm', source_name) }} as {{ source_name }}_{{ column_name }}
                on {{ source_name }}_{{ column_name }}.{{ source_name }}id = repivoted.{{ column_name }}_value
        {% endfor %}
    {% endfor %}
)

select *
from joined_friendly_names
{% endmacro %}