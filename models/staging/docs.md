# Table Definitions
{% docs account_table %} 
An account is a customer account that collects all of the critical information about the customer, such as contact information, payment terms, and payment methods. 
{% enddocs %}

{% docs accounting_code_table %} 
Grabs accounting values to help aggregate Zuora transaction data.
{% enddocs %}

{% docs amendment_table %}
When a customer needs to make a change to a subscription, you make that change through an amendment. Common subscription changes include 'Changing the terms and conditions of a contract; add a product or update an existing product to a subscription; renew, cancel, suspend or resume a subscription.'
{% enddocs %}

{% docs contact_table %}
Customer who holds an account or who is otherwise a person to contact about an account. 
{% enddocs %}

{% docs credit_balance_adjustment_table %}
An adjustment to change a customer's credit balance.  Applies adjustments to credit balances on billing accounts. This includes applying credit balance to invoices and transferring an invoice to a credit balance.
{% enddocs %}

{% docs invoice_table %} 
An invoice represents a bill to a customer, providing information about customers' accounts for invoices, including dates, status, and amounts. It is created at the account level, and can include all of the charges for multiple subscriptions for an account.
{% enddocs %}

{% docs invoice_item_table %} 
An invoice item is an individual line item in an invoice. Invoice items are charges, such as a monthly recurring charge.
{% enddocs %}

{% docs journal_entry_table %}
A journal entry in Zuora is a summary of all Zuora transactions, such as account receivables, credit balance adjustment, and revenue.
{% enddocs %}

{% docs journal_entry_item_table %}
Table containing individual line items of a transaction associated with a journal entry.
{% enddocs %}

{% docs order_table %}
Orders are contractual agreements between merchants and customers. You can create multiple subscriptions and subscription amendments at once in a single order. All the operations on subscriptions in orders are done by order actions. 
{% enddocs %}

{% docs order_item_table %}
An order item is a sales item within an order in the context of the recurring subscription business model. It can be a unit of products or service, but defined by both quantity and term (the start and end dates).
{% enddocs %}

{% docs payment_table %}
A payment is the money that customers send to pay for invoices related to their subscriptions
{% enddocs %}

{% docs payment_method_table %}
Payment methods are the ways in which customers pay for their subscriptions. Your customers can choose a payment method from your company's list of preferred payment methods.
{% enddocs %}

{% docs product_table %}
A product is an item or service that your company sells. In the subscription economy, a product is generally a service that your customers subscribe to rather than a physical item that they purchase one time. 
{% enddocs %}

{% docs product_rate_plan_table %}
A product rate plan is the part of a product that your customers subscribe to. Each product can have multiple product rate plans, and each product rate plan can have multiple product rate plan charges, which are fees for products and their product rate plans.
{% enddocs %}

{% docs product_rate_plan_charge_table %}
A product rate plan charge represents a charge model or a set of fees associated with a product rate plan, which is the part of a product that your customers subscribe to. Each product rate plan can have multiple product rate plan charges.
{% enddocs %}

{% docs rate_plan_table %}
A rate plan is part of a subscription or an amendment to a subscription, and it comes from a product rate plan.  Rate plans represent a price or a collection of prices for a service you sell. An individual rate plan contains all charges specific to a particular subscription.
{% enddocs %}

{% docs rate_plan_charge_table %}
A rate plan charge is part of a subscription or an amendment to a subscription, and it comes from a product rate plan charge. Rate plan charges represent the actual charges for the rate plans or services that you sell.
{% enddocs %}

{% docs refund_table %}
A refund returns money to a customer - as opposed to a credit, which creates a customer credit balance that may be applied to reduce the amount owed to you. Electronic refunds are processed by Zuora via a payment gateway.
External refunds indicate that the refund was processed outside of Zuora, say by a check, and the transaction must be recorded.
{% enddocs %}

{% docs refund_invoice_payment_table %}
This table exports information on refunds attributed to invoice payments.
{% enddocs %}

{% docs subscription_table %}
A subscription is a product or service that has recurring charges, such as a monthly flat fee or charges based on usage. Subscriptions can also include one-time charges, such as activation fees. Every subscription must be associated with an account. At least one active account must exist before any subscriptions can be created.
{% enddocs %}

{% docs taxation_item_table %}
Used to add a tax amount to an invoice item. Changes that you make with this object affect the product charges in your product catalog, but not the charges in existing subscriptions. To change taxes in existing subscriptions, you need to amend the subscription - remove the existing charge and replace it with the modified charge.
{% enddocs %}
# Field Definitions and References
{% docs account_id %}
{% enddocs %}

{% docs bill_to_contact_id %}
Person that you would like to bill or send the invoice to.
{% enddocs %}

{% docs contact_id %}
{% enddocs %}

{% docs currency %}
Currency the customer is billed in.
{% enddocs %}

{% docs created_date %}
Creation date for 
{% enddocs %}

{% docs created_by_id %}
Identifier of the user who created 
{% enddocs %}

{% docs default_payment_method_id %}
Identifier of the default payment method for the account.
{% enddocs %}

{% docs _fivetran_synced %}
Timestamp of when a record was last synced.
{% enddocs %}

{% docs _fivetran_deleted %}
Boolean identifiying whether the record was deleted in the source.
{% enddocs %}

{% docs home_currency %}
Home currency the customer is billed in.
{% enddocs %}

{% docs id %}
The unique identifier of the 
{% enddocs %}

{% docs is_most_recent_record %}
Is this the most recent record of 
{% enddocs %}

{% docs product_id %}
{% enddocs %}


{% docs sold_to_contact_id %}
Person that you have sold your product or services to; can be the same as the bill to contact.
{% enddocs %}

{% docs transaction_currency %}
Transaction currency the customer is billed in.
{% enddocs %}

{% docs updated_by_id %}
Identifier of the user who last updated 
{% enddocs %}

{% docs updated_date %}
Last updated date for 
{% enddocs %}