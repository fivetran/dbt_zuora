# dbt_zuora v0.UPDATE.UPDATE
 ## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_zuora v0.1.0
🎉 This is the initial release of this package! 🎉
## 📣 What does this dbt package do?
- Produces modeled tables that leverage Zuora data from [Fivetran's connector](https://fivetran.com/docs/applications/zuora) in the format described by [this ERD](https://fivetran.com/docs/applications/zuora#schemainformation) and build off the output of our [Zuora source package](https://github.com/fivetran/dbt_zuora_source).
- The above mentioned models enable you to better understand your Zuora performance metrics at different granularities. It achieves this by:
    - Providing intuitive reporting at the account and the subscription levels.
    - Creates a billing history model at the invoice level and a line item history model to evaluate data at the invoice item level. 
    - Builds a daily overview of account balance activity using the billing history data. 
    - Generates a monthly recurring revenue table at the account level. 
    - A churn analysis model is also available in the analysis folder to evaluate account churn at the monthly level. More details area available in the [DECISIONLOG](https://github.com/fivetran/dbt_zuora/blob/main/DECISIONLOG.md).
- Generates a comprehensive data dictionary of your source and modeled Zuora data through the [dbt docs site](https://fivetran.github.io/dbt_zuora/).
 
For more information, refer to the [README](https://github.com/fivetran/dbt_zuora/blob/main/README.md).