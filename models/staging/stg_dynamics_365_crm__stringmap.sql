select
    stringmapid,
    cast(attributevalue as {{ dbt.type_string()}}) as attributevalue,
    cast(attributename as {{ dbt.type_string()}}) as attributename,
    cast(objecttypecode as {{ dbt.type_string()}}) as objecttypecode,
    cast(value as {{ dbt.type_string()}}) as stringmap_value
from {{ var('stringmap') }}
where not coalesce(_fivetran_deleted, false)