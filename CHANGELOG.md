# dbt_dynamics_365_crm v0.1.0-b1
[PR #4](https://github.com/fivetran/dbt_dynamics_365_crm/pull/4) includes the following updates:

## Beta Release
- This release marks the transition from private preview to beta, making it available to a broader group of users. The feature is still in active development, and currently supports a limited set of tables. If you need access to additional tables, please submit a [feature request](https://github.com/fivetran/dbt_dynamics_365_crm/issues/new/choose).

## Feature Updates
- Addition of new stringmap output models. These new stringmap tables mirror the existing models by adding human-readable labels for fields (created as `<field_name>_label`) that store coded values (e.g., integer codes or option sets). These new output models include:
    - `msdyn_customerasset`
    - `msdyn_workorderproduct`
    - `msdyn_workorder`

# dbt_dynamics_365_crm v0.1.0-a2

[PR #3](https://github.com/fivetran/dbt_dynamics_365_crm/pull/3) includes the following updates:

## Feature Updates
- Addition of new stringmap output models. These new stringmap tables mirror the existing models by adding human-readable labels for fields (created as `<field_name>_label`) that store coded values (e.g., integer codes or option sets). These new output models include:
    - `email`
    - `task`

## Under the Hood
- Updates to the seed data to reflect the newly supported models.
- Update to the integrity validation test to account for the new models.

# dbt_dynamics_365_crm v0.1.0-a1
This is the initial release of this package.

## What does this dbt package do?

This package models Microsoft Dynamics 365 CRM data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm). It uses data in the format described by [this ERD](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm#schemainformation).

The main focus of the package is to enhance the Microsoft Dynamics 365 CRM data by adding human-readable labels for fields (created as `<field_name>_label`) that store coded values (e.g., integer codes or option sets). This package integrates stringmaps into the source tables, translating codes into meaningful labels.
