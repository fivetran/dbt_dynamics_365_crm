{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

{% set tables_names = [] %}
{% for table_name in [
    'account', 'appointment', 'contact', 'incident', 'msdyn_customerasset', 'msdyn_workorderproduct', 'msdyn_workorder', 'opportunity', 'phonecall', 'email', 'task', 'systemuser'
    ] if var('dynamics_365_crm_using_' ~ table_name, True) %}
    {% do tables_names.append(table_name) %}
{% endfor %}

with source_counts as (
    {% for table_name in tables_names %}
        select 
            count(*) as source_row_count,
            {{ "'" ~ table_name ~ "'" }} as source_name
        from {{ source('dynamics_365_crm', table_name) }}

        {{ 'union all ' if not loop.last }}
    {% endfor %}

), mapped_counts as (
    {% for table_name in tables_names %}
        select 
            count(*) as mapped_row_count,
            {{ "'" ~ table_name ~ "'" }} as mapped_name
        from {{ ref(table_name) }}

        {{ 'union all ' if not loop.last }}
    {% endfor %}
)

-- Produce rows if any row counts do not match
select 
    source_name,
    source_row_count,
    mapped_row_count
from source_counts
inner join mapped_counts
    on source_name = mapped_name
    and source_row_count != mapped_row_count