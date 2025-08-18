{% macro get_rate_plan_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "amendment_id", "datatype": dbt.type_string()}, 
    {"name": "bill_to_contact_id", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "default_payment_method_id", "datatype": dbt.type_string()}, 
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "original_rate_plan_id", "datatype": dbt.type_string()}, 
    {"name": "product_id", "datatype": dbt.type_string()},
    {"name": "product_rate_plan_id", "datatype": dbt.type_string()},
    {"name": "sold_to_contact_id", "datatype": dbt.type_string()},
    {"name": "subscription_id", "datatype": dbt.type_string()}, 
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}
] %}


{{ fivetran_utils.add_pass_through_columns(columns, var('zuora_rate_plan_pass_through_columns')) }} 

{{ return(columns) }}

{% endmacro %}
