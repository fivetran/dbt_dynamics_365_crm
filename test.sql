{%- set columns = adapter.get_columns_in_relation(source('dynamics365', 'contact')) -%}
{%- set attributes = dbt_utils.get_column_values(table=source('dynamics365', 'stringmap'), column='attributename') -%}

{%- set fields = [] -%}
{%- set non_pivot_fields = [] -%}
{%- for col in columns -%}
    {%- if col.name in attributes -%}
        {%- do fields.append(col.name) -%}
    {%- else -%}
        {%- do non_pivot_fields.append(col.name) -%}
    {%- endif -%}
{%- endfor -%}

with contact_unpivoted as (
    {{ dbt_utils.unpivot(
        relation=source('dynamics365', 'contact'),
        cast_to=dbt.type_string(),
        exclude=non_pivot_fields,
        field_name="fieldname",
        value_name="fieldvalue"
    ) }}
),
stringmaps as (
    select 
        cast(attributevalue as string) as attributevalue,
        cast(attributename as string) as attributename,
        value
    from {{ source('dynamics365', 'stringmap') }}
    where lower(objecttypecode) = 'contact'
),
joined as (
    select
        contact_unpivoted.*,
        coalesce(stringmaps.value, contact_unpivoted.fieldvalue) as fieldvalue_name -- this is in case there isn't a match
    from contact_unpivoted
    left join stringmaps
    on lower(contact_unpivoted.fieldname) = lower(stringmaps.attributename)
    and lower(contact_unpivoted.fieldvalue) = lower(stringmaps.attributevalue)
),

repivoted as (
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