# dbt_dynamics_365_crm v0.2.0-a1
[PR #12](https://github.com/fivetran/dbt_dynamics_365_crm/pull/12) includes the following updates:

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_dynamics_365_crm.yml`.

### Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.


# dbt_dynamics_365_crm v0.1.0-b2
[PR #7](https://github.com/fivetran/dbt_dynamics_365_crm/pull/7) includes the following updates:

## Bug fixes
- Updated the `string_mapping` macro to produce significantly fewer lines, reducing the risk of query length–related errors.
  - The macro now requires two arguments: `table_name` and `primary_key`, and all dependent models have been updated accordingly.

## Under the hood
- Updated seed files to include the correct primary key names.
- Added consistency tests.

# dbt_dynamics_365_crm v0.1.0-b1
[PR #4](https://github.com/fivetran/dbt_dynamics_365_crm/pull/4) includes the following updates:

## Beta Release
- This release marks the transition from private preview to beta, making it available to a broader group of users. The feature is still in active development, and currently supports a limited set of tables. If you need access to additional tables, please submit a [feature request](https://github.com/fivetran/dbt_dynamics_365_crm/issues/new/choose).

## Feature Updates
- Addition of new stringmap output models. These new stringmap tables mirror the existing models by adding human-readable labels for fields (created as `<field_name>_label`) that store coded values (e.g., integer codes or option sets). These new output models include:
    - `msdyn_customerasset`
    - `msdyn_workorderproduct`
    - `msdyn_workorder`
- Updated the `string_mapping` macro to prefer the `renamed_attributename` field, if available, over `attributename`. Fivetran introduced `renamed_attributename` to better align with the field values used in downstream tables, but `attributename` is still supported for backward compatibility.

## Under the Hood
- Corrected the `enabled` YAML configuration for source definitions.
- Updated the `auto-release` workflow to the updated version.
- Added the `generate-docs` workflow. 

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
