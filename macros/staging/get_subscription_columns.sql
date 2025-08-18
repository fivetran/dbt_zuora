{% macro get_subscription_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "auto_renew", "datatype": "boolean"},
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "cancel_reason", "datatype": dbt.type_string()},
    {"name": "cancelled_date", "datatype": dbt.type_timestamp()},
    {"name": "contract_acceptance_date", "datatype": dbt.type_timestamp()},
    {"name": "contract_effective_date", "datatype": dbt.type_timestamp()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "current_term", "datatype": dbt.type_int()},
    {"name": "current_term_period_type", "datatype": dbt.type_string()}, 
    {"name": "default_payment_method_id", "datatype": dbt.type_string()},
    {"name": "externally_managed_by", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "initial_term", "datatype": dbt.type_int()},
    {"name": "initial_term_period_type", "datatype": dbt.type_string()},
    {"name": "invoice_owner_id", "datatype": dbt.type_string()},
    {"name": "is_invoice_separate", "datatype": "boolean"},
    {"name": "is_latest_version", "datatype": "boolean"},
    {"name": "last_booking_date", "datatype": "date"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "original_created_date", "datatype": dbt.type_timestamp()},
    {"name": "original_id", "datatype": dbt.type_string()},
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "payment_term", "datatype": dbt.type_string()},
    {"name": "previous_subscription_id", "datatype": dbt.type_string()},
    {"name": "renewal_term", "datatype": dbt.type_int()},
    {"name": "renewal_term_period_type", "datatype": dbt.type_string()},
    {"name": "revision", "datatype": dbt.type_string()},
    {"name": "service_activation_date", "datatype": dbt.type_timestamp()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "subscription_end_date", "datatype": dbt.type_timestamp()},
    {"name": "subscription_start_date", "datatype": dbt.type_timestamp()},
    {"name": "term_end_date", "datatype": dbt.type_timestamp()},
    {"name": "term_start_date", "datatype": dbt.type_timestamp()},
    {"name": "term_type", "datatype": dbt.type_string()}, 
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()},
    {"name": "version", "datatype": dbt.type_int()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('zuora_subscription_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}