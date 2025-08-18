{% macro get_account_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_number", "datatype": dbt.type_string()},
    {"name": "auto_pay", "datatype": "boolean"},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "batch", "datatype": dbt.type_string()},
    {"name": "bill_cycle_day", "datatype": dbt.type_int()},
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "credit_balance", "datatype": dbt.type_float()},
    {"name": "crm_id", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "default_payment_method_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_invoice_date", "datatype": dbt.type_timestamp()},
    {"name": "mrr", "datatype": dbt.type_float()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "payment_term", "datatype": dbt.type_string()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()}, 
    {"name": "tax_exempt_effective_date", "datatype": dbt.type_timestamp()},
    {"name": "tax_exempt_expiration_date", "datatype": dbt.type_timestamp()},
    {"name": "tax_exempt_status", "datatype": dbt.type_string()}, 
    {"name": "total_debit_memo_balance", "datatype": dbt.type_float()},
    {"name": "total_invoice_balance", "datatype": dbt.type_float()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()},
    {"name": "vatid", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('zuora_account_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}