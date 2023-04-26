# Decision Log
## Track Zuora transactions utilizing the `zuora__biling_history` and `zuora__revenue_line_item_history` models
To track Zuora transactions and various charges, it was determined there are two levels that will be most helpful to the end user
* Pulling Zuora data at the invoice level to understand the history of invoice, payments, taxes, discounts, and credit balance adjustments. That information can be found [in the billing history model](https://github.com/fivetran/dbt_zuora/blob/main/models/zuora__billing_history.sql).
* Pulling Zuora data at the invoice item level to associate these transaction types with various products, rate plans, and rate plan charges. This information can be found [in the line item history model](https://github.com/fivetran/dbt_zuora/blob/main/models/zuora__line_item_history.sql).

## Evaluate Zuora monthly recurring revenue at the account or the charge level with the `zuora__monthly_recurring_revenue` and `zuora__line_item_history` models respectively.
Zuora customers can utilize the `zuora__monthly_recurring_revenue` model to make MRR calculations at the account level. If Zuora customers would like to dig deeper, they can utilize the `zuora__line_item_history` model using `invoice_item_id` as the lowest grain and then aggregating by various charge fields. They'll have `gross_revenue`, `discount_revenue`, `net_revenue` measures available to them for finding MRR at the charge level. We also have `mrr_expected_current_month` and `mrr_expected_home_currency_current_month` fields from `rate_plan_charge` that are expected MRR values but might not necessarily be the actual MRR billed out, so it's brought in for comparison.

## Zuora amount distinctions between monthly recurring revenue and billing history
You might notice discrepancies between the `zuora__monthly_recurring_revenue` monthly totals and `zuora__account_daily_overview` amounts. 
* This is because `zuora__monthly_recurring_revenue` looks at the `service_start_month` grain for when to evaluate revenue totals since revenue usually bills out at the start of a subscription service. 
* On the other side, `zuora__account_daily_overview` is looking at a history of billings, so we use the `invoice_date` grain, since that is usually when an account gets billed out.

We felt this made the most sense for each of these models in billing and revenue recognition, but we'd love to get your feedback on this approach [in our Fivetran dbt community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group)!

## Use `zuora__account_churn_analysis` in our analysis folder to examine churn at the monthly level
Customers can evaluate churn at numerous levels. In Zuora, [the general glossary evaluation of churn is at the account level](https://knowledgecenter.zuora.com/Zuora_Central_Platform/Analytics/Analytics_Quick_Reference/Analytics_metric_glossary) and examining whether rate plan charges recur at the monthly level. We evaluate churn in the `zuora__account_churn_analysis` model in the analysis folder using this method, where you can utilize this compiled code to calculate churn more effectively.

To slice general churn by various grains like subscription, rate plan charges, products, utilize the `zuora__line_item_history` and `zuora__subscription_overview` models to gather the needed information to calculate churn. You can use charge date values to compile the necessary billing periods.