{{ config(
    tags="fivetran_validations",
    enabled=(var('fivetran_validation_tests_enabled', false) and var('dynamics_365_crm_using_msdyn_workorderproduct', true))
) }}

with prod as (
    select *
    from {{ target.schema }}_dynamics_365_crm_prod.msdyn_workorderproduct
),

dev as (
    select *
    from {{ target.schema }}_dynamics_365_crm_dev.msdyn_workorderproduct
), 

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final