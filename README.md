<!--section="dynamics-365-crm_transformation_model"-->
# Microsoft Dynamics 365 CRM dbt Package

This dbt package transforms data from Fivetran's Microsoft Dynamics 365 CRM connector into analytics-ready tables.

## Resources

- Number of materialized models¹:
  - Quickstart users: varies (one model per source table in your Dynamics 365 CRM connection)
  - dbt Core users: 12
- Connector documentation
  - [Dynamics 365 CRM connector documentation](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm)
  - [Dynamics 365 CRM ERD](https://fivetran.com/docs/connectors/applications/microsoft-dynamics/dynamics365crm#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_dynamics_365_crm)
  - [dbt Docs](https://fivetran.github.io/dbt_dynamics_365_crm/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_dynamics_365_crm/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_dynamics_365_crm/blob/main/CHANGELOG.md)
- dbt Core™ supported versions
  - `>=1.3.0, <3.0.0`

## What does this dbt package do?
This package enables you to enhance Microsoft Dynamics 365 CRM data by adding human-readable labels for coded values and integrate stringmaps into source tables. It creates enriched models with metrics focused on translating codes into meaningful labels for better data analysis.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_dynamics_365_crm
```

### Final output tables

#### For Quickstart Users

When using Fivetran Quickstart, this package utilizes **dynamic model generation** based on your specific Dynamics 365 CRM configuration. **For each source table in your Dynamics 365 CRM instance, a corresponding enriched model will be created** with stringmap labels applied.

**Dynamic Model Structure:**
| Output Model | Description |
| :---- | :---- |
| `<your_source_table_name>` | Each source table from your Dynamics 365 CRM instance, enriched with human-readable labels for coded fields. Stringmap labels are added as `<field_name>_label` columns alongside the original coded values. |

**Example:** If your Dynamics 365 CRM instance has tables like `account`, `contact`, `custom_entity_abc`, and `opportunity`, you'll get corresponding enriched models: `account`, `contact`, `custom_entity_abc`, and `opportunity`, each with stringmap labels applied where available.

> **Note:** Quickstart users may or may not have the standard tables listed below, as their models are generated dynamically based on their specific Dynamics 365 CRM setup and enabled entities.

#### For dbt Core Users

By default, this package materializes the following final tables for dbt Core users:

| Table | Description |
| :---- | :---- |
| [`account`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.account) | Model representing accounts in Dynamics 365 CRM, enriched with human-readable column names for fields with corresponding stringmap labels created as `<field_name>_label`. |
| [`appointment`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.appointment) | Model representing appointments in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`contact`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.contact) | Model for contacts in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`email`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.email) | Model for emails in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`incident`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.incident) | Model for incidents in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`msdyn_customerasset`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.msdyn_customerasset) | Model for customer assets in Dynamics 365 Field Service, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`msdyn_workorder`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.msdyn_workorder) | Model for work orders in Dynamics 365 Field Service, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`msdyn_workorderproduct`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.msdyn_workorderproduct) | Model for work order products in Dynamics 365 Field Service, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`opportunity`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.opportunity) | Model for opportunities in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`phonecall`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.phonecall) | Model for phone calls in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`systemuser`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.systemuser) | Model for system users in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |
| [`task`](https://fivetran.github.io/dbt_dynamics_365_crm/#!/model/model.dynamics_365_crm.task) | Model for tasks in Dynamics 365 CRM, enriched with human-readable column names for fields with stringmap labels created as `<field_name>_label`. |

> **Note:** To extend beyond these standard models and create custom stringmapped models for your organization's specific entities, see the [Additional configurations](#optional-additional-configurations) section below.

¹ Each dbt Core transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`. For Quickstart users, the number of models will vary based on dynamic model generation.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Dynamics 365 CRM connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_dynamics_365_crm/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following Microsoft Dynamics 365 CRM package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/dynamics_365_crm
    version: [">=0.3.0", "<0.4.0"]
```

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables

By default, this package runs using your destination and the `dynamics_365` schema. If this is not where your Microsoft Dynamics 365 CRM data is (for example, if your Microsoft Dynamics 365 CRM schema is named `dynamics_365_crm_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  dynamics_365_crm_database: your_database_name
  dynamics_365_crm_schema: your_schema_name 
```

### Enable/Disable Variables
By default, this package brings in data from the Microsoft Dynamics 365 CRM source tables listed in [`models/src_dynamics_365_crm.yml`](https://github.com/fivetran/dbt_dynamics_365_crm/blob/main/models/src_dynamics_365_crm.yml). However, if you have disabled syncing any of these sources, you will need to add the following configuration to your `dbt_project.yml`:

```yml
vars:
    dynamics_365_crm_using_<default_source_table_name>: false # default = true
```

### (Optional) Additional configurations
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

```yml
vars:
    dynamics_365_crm_<default_source_table_name>_identifier: your_table_name 
```

#### Adding Custom Models (dbt Core Users)
To map custom entities with the `dynamics_365_crm.string_mapping` macro:

1. **Define the source table** in your project’s source YAML
2. **Create a model** using the `dynamics_365_crm.string_mapping` macro (one per source table) and include the `string_mapping` macro:

```sql
-- models/my_custom_entity.sql
{{
    dynamics_365_crm.string_mapping(
        table_name: 'my_custom_entity',
        primary_key: 'my_custom_entityid',
        run_mode: 'standard'
    )
}}
```

</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).
</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.0.0", "<2.0.0"]
```

<!--section="dynamics-365-crm_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/dynamics_365_crm/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_dynamics_365_crm/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_dynamics_365_crm/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
