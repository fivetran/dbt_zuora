{% macro get_taxation_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "account_receivable_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "accounting_code", "datatype": dbt.type_string()}, 
    {"name": "amendment_id", "datatype": dbt.type_string()},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "credit_amount", "datatype": dbt.type_float()}, 
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "exchange_rate_date", "datatype": dbt.type_timestamp()},
    {"name": "exempt_amount", "datatype": dbt.type_float()}, 
    {"name": "exempt_amount_home_currency", "datatype": dbt.type_int()}, 
    {"name": "home_currency", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "invoice_item_id", "datatype": dbt.type_string()},
    {"name": "journal_entry_id", "datatype": dbt.type_string()},
    {"name": "journal_run_id", "datatype": dbt.type_string()}, 
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "payment_amount", "datatype": dbt.type_float()},
    {"name": "product_id", "datatype": dbt.type_string()},
    {"name": "product_rate_plan_charge_id", "datatype": dbt.type_string()},
    {"name": "product_rate_plan_id", "datatype": dbt.type_string()}, 
    {"name": "rate_plan_charge_id", "datatype": dbt.type_string()},
    {"name": "rate_plan_id", "datatype": dbt.type_string()},
    {"name": "sales_tax_payable_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "subscription_id", "datatype": dbt.type_string()},
    {"name": "tax_amount", "datatype": dbt.type_float()}, 
    {"name": "tax_amount_home_currency", "datatype": dbt.type_float()}, 
    {"name": "tax_date", "datatype": dbt.type_timestamp()},
    {"name": "tax_description", "datatype": dbt.type_string()},
    {"name": "tax_mode", "datatype": dbt.type_string()},
    {"name": "tax_rate", "datatype": dbt.type_float()},
    {"name": "tax_rate_type", "datatype": dbt.type_string()},
    {"name": "transaction_currency", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}