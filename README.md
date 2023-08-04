<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_zuora/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Zuora dbt package ([Docs](https://fivetran.github.io/dbt_zuora/)) 

# 📣 What does this dbt package do?
- Produces modeled tables that leverage Zuora data from [Fivetran's connector](https://fivetran.com/docs/applications/zuora) in the format described by [this ERD](https://fivetran.com/docs/applications/zuora#schemainformation) and builds off the output of our [Zuora source package](https://github.com/fivetran/dbt_zuora_source).

- Enables you to better understand your Zuora data. The package achieves this by performing the following: 
    - Enhancing the balance transaction entries with useful fields from related tables 
    - Creating customized analysis tables to examine churn by subscriptions
    - Developing a look at gross, net, and discount monthly recurring revenue by account 
    - Generating metrics tables that allow you to better understand your account activity over time or at a customer level. These time-based metrics are available on a daily level.
- Generates a comprehensive data dictionary of your source and modeled Zuora data through the [dbt docs site](https://fivetran.github.io/dbt_zuora/).

The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_zuora/#!/overview?g_v=1).
 
| **model**                         | **description** |                                                                                                                               
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [zuora_account_daily_overview](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__account_daily_overview)    |  Each record is a day in an account and its accumulated balance totals based on all line item transactions up to that day.                            |
| [zuora_account_overview](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__account_overview)    |  Each record represents an account, enriched with metrics about their associated transactions.                                                                                                     |
| [zuora_billing_history](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__billing_history)    | Each record represents an invoice and its various transaction details. |
| [zuora_line_item_history](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__line_item_history)      | Each record represents a specific invoice item and its various transaction details.                                                                     |                                                              
| [zuora__monthly_recurring_revenue](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__monthly_recurring_revenue) | Each record represents an account and MRR generated on a monthly basis. |
| [zuora__subscription_overview](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__subscription_overview)       | Each record represents a subscription, enriched with metrics about time, revenue, state, and period.    

An example churn model is separately available in the analysis folder: 
| **analysis model**   | **description**   |
|---------------------|------------------|
| [zuora__account_churn_analysis](https://fivetran.github.io/dbt_zuora/#!/analysis/analysis.zuora.zuora__account_churn_analysis) | Each record represents an account and whether it has churned in that month or not. | 

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Zuora connector syncing data into your destination 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, **Databricks** destination

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package, you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages, respectively.

```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package
Include the following zuora_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/zuora
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```
Do NOT include the `zuora_source` package in this file. The transformation package itself has a dependency on it and will install the source package as well.


## Step 3: Define database and schema variables
By default, this package runs using your destination and the `zuora` schema. If this is not where your Zuora data is (for example, if your Zuora schema is named `zuora_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    zuora_database: your_destination_name
    zuora_schema: your_schema_name 
```

## Step 4: Disable models for non-existent sources
Your Zuora connector may not be syncing all tabes that this package references. This might be because you are excluding those tables. If you are not using those tables, you can disable the corresponding functionality in the package by specifying the variable in your dbt_project.yml. By default, all packages are assumed to be true. You only have to add variables for tables you want to disable in the following way:

```yml 
vars: 
  zuora__using_credit_balance_adjustment: false # Disable if you do not have the credit balance adjustment table
  zuora__using_refund: false # Disable if you do not have the refund table
  zuora__using_refund_invoice_payment: false # Disable if you do not have the refund invoice payment table
  zuora__using_taxation_item: false # Disable if you do not have the taxation item table
```     

## Step 5: Configure the multicurrency variable for customers billing in multiple currencies
Zuora allows the functionality for multicurrency to bill customers in various currencies. If you are an account utilizing multicurrency, make sure to set the `zuora__using_multicurrency` variable to `true` in `dbt_project.yml` so the amounts in our data models accurately reflect the home currency values in your native account currency.

```yml
vars:
  zuora__using_multicurrency: false #Enable if you are utilizing multicurrency, false by default.
```
### Multicurrency Support Disclaimer (and how you can help)
We were not able to develop the package using the multicurrency variable, so we had to execute our best judgement when building these models. If you encounter any issues with enabling the variable, [please file a bug report with us](https://github.com/fivetran/dbt_zuora/issues/new?assignees=&labels=type%3Abug&template=bug-report.yml&title=%5BBug%5D+%3Ctitle%3E) and we can work together to fix any issues you encounter!

## (Optional) Step 6: Additional configurations
<details><summary>Expand to view configurations</summary>

### Setting the date range for the account daily overview and monthly recurring revenue models
By default, the `zuora__account_daily_overview` will aggregate data for the entire date range of your data set based on the minimum and maximum `invoice_date` values from the `invoice` source table, and `zuora__monthly_recurring_revenue` based on the `service_start_date` from the `invoice_item` source table. 

However, you may limit this date range if desired by defining the following variables for each respective model (the `zuora_overview_` variables refer to the `zuora__account_daily_overview`, the `zuora_mrr_` variables apply to `zuora__monthly_recurring_revenue`). 

```yml
vars:
    zuora_daily_overview_first_date: "yyyy-mm-dd"
    zuora_daily_overview_last_date: "yyyy-mm-dd"

    zuora_mrr_first_date: "yyyy-mm-dd"
    zuora_mrr_last_date: "yyyy-mm-dd"
```

### Passing Through Additional Fields
This package includes all source columns defined in the [macros folder of the dbt_zuora_source package](https://github.com/fivetran/dbt_zuora_source/tree/main/macros). You can add more columns using our pass-through column variables. These variables allow the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a SQL snippet within the `transform_sql` key. You may add the desired SQL while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
vars:
  zuora_account_pass_through_columns: 
    - name: "new_custom_field"
      alias: "custom_field"
      transform_sql: "cast(custom_field as string)"
    - name: "another_one"
  zuora_subscription_pass_through_columns:
    - name: "this_field"
      alias: "cool_field_name"
  zuora_rate_plan_pass_through_columns:
    - name: "another_field"
      alias: "cooler_field_name"
  zuora_rate_plan_charge_pass_through_columns:
    - name: "yet_another_field"
      alias: "coolest_field_name"
```
### Change the build schema
By default this, package will build the Zuora staging models within a schema titled (<target_schema> + `_stg_zuora`), the Zuora intermediate models within a schema titled (<target_schema> + `_zuora_int`), and the Zuora final models within a schema titled (<target_schema> + `_zuora`) in your target database. If this is not where you would like your modeled Zuora data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
  zuora:
    +schema: my_new_schema_name # leave blank for just the target_schema
    intermediate:
      +schema: my_new_schema_name # leave blank for just the target_schema
  zuora_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_zuora_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    zuora_<default_source_table_name>_identifier: your_table_name 
```

### 🚨 Snowflake Users
If you do **not** use the default all-caps naming conventions for Snowflake, you may need to provide the case-sensitive spelling of your source tables that are also Snowflake reserved words. 

In this package, this would apply to the `ORDER` source. If you are receiving errors for this source, include the below identifier in your `dbt_project.yml` file:

```yml
vars:
    zuora_order_identifier: "ORDER" # as an example, must include the double-quotes and correct case!
```  
  
</details>

## (Optional) Step 7: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand to view details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>
    
# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/zuora_source
      version: [">=0.1.0", "<0.2.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
          
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/zuora/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_zuora/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

## Opinionated Modelling Decisions
This dbt package takes several opinionated stances in order to provide the customer several options to better understand key subscription metrics. Those include:
- Evaluating a history of billing transactions, examined at either the invoice or invoice item level
- How to calculate monthly recurring revenue and at which grains to assess it, either looking at it granularly at the charge (invoice item) or account monthly level
- Developing a custom churn analysis that you can find in the analysis folder that's built on the account monthly level, but also giving the customer the ability to look at churn from a subscription or rate plan charge level.

If you would like a deeper explanation of the decisions we made to our models in this dbt package, you may reference the [DECISIONLOG](https://github.com/fivetran/dbt_zuora/blob/main/DECISIONLOG.md).

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_zuora_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Submit any questions you have about our packages [in our Fivetran dbt community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) so our Engineering team can provide guidance as quickly as possible!
