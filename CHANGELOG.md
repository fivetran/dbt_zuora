# dbt_zuora v0.3.0
[PR #12](https://github.com/fivetran/dbt_zuora/pull/12) includes the following breaking changes:

## Feature Updates
- Introduced the new `zuora__line_item_enhanced` model. This model includes a line item enriched with invoice, subscription, payment, and refund information. This model has been built with the intention of retaining a common line item schema across all other Fivetran billing data models.

## Under the Hood:
- Updated the pull request templates.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_zuora v0.2.1
[PR #10](https://github.com/fivetran/dbt_zuora/pull/10) includes the following breaking changes:
## 🔧 Fixes
- Updated `zuora__line_item_history` so that all `tax_amount_home_currency` values associated with a given `invoice_item_id` are summed rather than simply joined. This ensures the grain for this model is kept at the `invoice_item_id` level.
- Updated surrogate key `subscription_key` in `zuora__subscription_overview` to include `amendment_id`. This accounts for multiple amendments associated with the same record.

# dbt_zuora v0.2.0
[PR #8](https://github.com/fivetran/dbt_zuora/pull/8) includes the following breaking changes:

## 🚨 Breaking Changes 🚨
- Redesigned `zuora__billing_history` so `invoice_id` was the actual grain, accounting for the cases when invoices can be tied to multiple credit balance adjustments and payments. This required the following steps:
    - All metrics associated with `credit_balance_adjustment_id` in `int_zuora__billing_enriched` were aggregated on the invoice level (number of credit balance adjustments,total credit balance amount in home currency, first and last dates of credit balance adjustments on the invoice). Fields associated with an individual `credit_balance_adjustment_id` were removed.
    - All metrics associated with `payment_id` in `int_zuora__billing_enriched` were aggregated on the invoice level (number of payments, total payment amount in home currency, first and last dates of payments on the invoice). Fields associated with an individual `payment_id` were removed.
    - Aggregated count of `payment_method_id` to gather a count of payment methods on each invoice.
    - A full list of field changes in `zuora__billing_history` is provided below: 

| **[Zuora__billing_history](https://fivetran.github.io/dbt_zuora/#!/model/model.zuora.zuora__billing_history)** updates | **Field changes** |
| ---------- | -------------------- |
| Added payment fields | `payments`, `first_payment_date`, `most_recent_payment_date`, `payment_methods` |
| Modified payment fields  (aggregated line items) | `invoice_amount_unpaid_home_currency` |
| Removed payment fields |  `payment_id`, `payment_number`, `payment_date`, `payment_status`, `payment_type` |
| Added credit balance adjustment fields | `credit_balance_adjustments`, `first_credit_balance_adjustment_date`, `most_recent_credit_balance_adjustment_date` |
| Modified credit balance adjustment fields (aggregated line items) | `credit_balance_adjustment_amount_home_currency` |
| Removed credit balance adjustment fields | `credit_balance_adjustment_id`, `credit_balance_adjustment_number`, `credit_balance_adjustment_reason_code`, `credit_balance_adjustment_date` |
| Added payment method fields | `payment_methods` |
| Removed payment method fields | `payment_method_id`, `payment_method_type`, `payment_method_subtype`, `is_payment_method_active` | 

- Updated yml of `zuora__billing_history` with aggregated fields, and removed non-aggregated fields associated with credit balance adjustments, payments, and payment methods.
- Modified `int_zuora__account_enriched` to account for new aggregated metric fields being pulled from `zuora__billing_history`. 

## 🔧 Under The Hood 🔩
- Updated seed files in `integration_tests` to reproduce the initial `invoice_id` uniqueness test issue for multiple credit balance adjustments and payments for one invoice.

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
