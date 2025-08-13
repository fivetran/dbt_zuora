{% macro get_amendment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "auto_renew", "datatype": "boolean"},
    {"name": "booking_date", "datatype": "date"},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "contract_effective_date", "datatype": "date"},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "current_term", "datatype": dbt.type_int()},
    {"name": "current_term_period_type", "datatype": dbt.type_string()},
    {"name": "customer_acceptance_date", "datatype": "date"},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "effective_date", "datatype": "date"}, 
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "new_rate_plan_id", "datatype": dbt.type_string()},
    {"name": "removed_rate_plan_id", "datatype": dbt.type_string()},
    {"name": "renewal_setting", "datatype": dbt.type_string()},
    {"name": "renewal_term", "datatype": dbt.type_int()},
    {"name": "renewal_term_period_type", "datatype": dbt.type_string()},
    {"name": "resume_date", "datatype": "date"},
    {"name": "service_activation_date", "datatype": "date"},
    {"name": "specific_update_date", "datatype": "date"},
    {"name": "status", "datatype": dbt.type_string()}, 
    {"name": "subscription_id", "datatype": dbt.type_string()},
    {"name": "suspend_date", "datatype": "date"},
    {"name": "term_start_date", "datatype": "date"},
    {"name": "term_type", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
