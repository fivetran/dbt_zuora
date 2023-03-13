# dbt_zuora_source v0.1.0
🎉 This is the initial release of this package! 🎉
## 📣 What does this dbt package do?
- Materializes [Zuora staging tables](https://fivetran.github.io/dbt_zuora_source/#!/overview/Recharge_source/models/?g_v=1&g_e=seeds), which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/zuora#schemainformation). These staging tables clean, test, and prepare your Zuora data from [Fivetran's connector](https://fivetran.com/docs/applications/zuora) for analysis by doing the following:
  - Names columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Zuora data through the [dbt docs site](https://fivetran.github.io/dbt_zuora_source/).
- These tables are designed to work simultaneously with our [Zuora transformation package](https://github.com/fivetran/dbt_zuora).
- For more information refer to the [README](https://github.com/fivetran/dbt_zuora/blob/main/README.md).