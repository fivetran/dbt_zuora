# Zuora Analysis
> Note: The compiled sql within the `analyses` folder references the final models [zuora__account_daily_overview](https://github.com/fivetran/dbt_zuora/blob/main/models/zuora__account_daily_overview.sql) and [zuora__line_item_history](https://github.com/fivetran/dbt_zuora/blob/main/models/zuora__line_item_history.sql). Before you can compile and use the analysis SQL, you'll must execute a `dbt run` first.


## Analysis SQL
| **sql**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [zuora__account_churn_analysis](https://fivetran.github.io/dbt_zuora/#!/analysis/analysis.zuora.zuora__account_churn_analysis) | The output of the compiled sql will generate monthly account churn analysis by identifying when accounts transition from active to inactive status. The analysis provides insights into account retention patterns by tracking rate plan charges per account over time and flagging churned months when an account goes from having active charges to no active charges. The SQL references the `zuora__account_daily_overview` and `zuora__line_item_history` models and includes `source_relation` to support multi-connection setups. |

## SQL Compile Instructions
Leveraging the above sql is made possible by the [analysis functionality of dbt](https://docs.getdbt.com/docs/building-a-dbt-project/analyses/). In order to
compile the sql, you will perform the following steps:
- Execute `dbt run` to create the package models.
- Execute `dbt compile` to generate the target specific sql.
- Navigate to your project's `/target/compiled/zuora/analyses` directory.
- Copy the desired analysis code (`zuora__account_churn_analysis`) and run in your data warehouse.
- Confirm the account churn metrics match your expected subscription patterns.
- Analyze the monthly churn data to identify trends and patterns in customer retention and account lifecycle management.

## Contributions
Don't see a compiled sql statement you would have liked to be included? Notice any bugs when compiling
and running the analysis sql? If so, we highly encourage and welcome contributions to this package! If interested, the best first step is [opening a feature request](https://github.com/fivetran/dbt_zuora/issues/new?template=feature-request.yml).