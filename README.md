# Fivetran Platform dbt Package ([Docs](https://fivetran.github.io/dbt_fivetran_log/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_fivetran_log/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# Microsoft Dynamics 365 CRM dbt Package ([Docs](https://fivetran.github.io/dbt_dynamics_365_crm /))

## What does this dbt package do?

This package models Microsoft Dynamics 365 CRM data from [Fivetran's connector](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365CRM ). It uses data in the format described by [this ERD](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365CRM #schemainformation).

The main focus of the package is to...

<!--section="salesforce_marketing_cloud_transformation_model"-->
The following table provides a detailed list of all models materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_dynamics_365_crm /#!/overview).

| **Table** | **Description**|
| --------- | -------------- |

<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Microsoft Dynamics 365 CRM connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package
Include the following Microsoft Dynamics 365 CRM package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/dynamics_365_crm
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```

### Step 3: Define database and schema variables

By default, this package runs using your destination and the `dynamics_365_crm` schema. If this is not where your Microsoft Dynamics 365 CRM data is (for example, if your Microsoft Dynamics 365 CRM schema is named `dynamics_365_crm_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  dynamics_365_crm_database: your_database_name
  dynamics_365_crm_schema: your_schema_name 
```

### Step 4: Enable/Disable Variables
By default, this package brings in data from a select list of Microsoft Dynamics 365 CRM source tables. However, if you have disabled syncing these sources, you will need to add the following configuration to your `dbt_project.yml`:

```yml
vars:
    dynamics_365_crm_using_<default_source_table_name>: false # default = true
```

### (Optional) Step 5: Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Changing the Build Schema
By default this package will build the Microsoft Dynamics 365 CRM models within a schema titled (<target_schema> + `_dynamics_365_crm`) in your target database. If this is not where you would like your modeled Microsoft Dynamics 365 CRM data to be written, add the following configuration to your `dbt_project.yml` file:

```yml
models:
  dynamics_365_crm:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_dynamics_365_crm/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    dynamics_365_crm_<default_source_table_name>_identifier: your_table_name 
```
</details>

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>


## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/salesforce_marketing_cloud/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_dynamics_365_crm /blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_dynamics_365_crm /issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).