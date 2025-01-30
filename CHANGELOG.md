# dbt_dynamics_365_crm v0.1.0-a1
This is the initial release of this package.

## What does this dbt package do?

This package models Microsoft Dynamics 365 CRM data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm). It uses data in the format described by [this ERD](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm#schemainformation).

The main focus of the package is to enhance the Microsoft Dynamics 365 CRM data by adding human-readable labels for fields (created as `<field_name>_label`) that store coded values (e.g., integer codes or option sets). This package integrates stringmaps into the source tables, translating codes into meaningful labels.
