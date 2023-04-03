# Decision Log

## Track Zuora transactions utilizing `zuora__biling_history` and `zuora__revenue_line_item_history`
To track Zuora transactions and various charges, it was determined there are two levels that will be most helpful to the end user
* Pulling Zuora data at the invoice level to understand the history of invoice, payments, taxes, discounts, and credit balance adjustments. That information can be found in the `zuora__billing_history` model.
* Pulling Zuora data at the invoice item level to associate these transaction types with various products, rate plans, and rate plan charges. This information can be found in the `zuora__revenue_line_item_history model.

## Zuora MRR calculations at the account and charge level
Zuora customers can utilize the `zuora__monthly_recurring_revenue` model to make MRR calculations at the account level. If Zuora customers would like to dig deeper, they can utilize the `zuora__revenue_line_item_history` model using `invoice_item_id` as the lowest grain and then aggregating by various charge fields. They'll have `gross_revenue`, `discount_revenue`, `net_revenue` measures available to them for finding MRR at the charge level.