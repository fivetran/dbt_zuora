{% macro get_product_rate_plan_charge_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "account_receivable_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "accounting_code", "datatype": dbt.type_string()},
    {"name": "apply_discount_to", "datatype": dbt.type_string()},
    {"name": "bill_cycle_day", "datatype": dbt.type_int()},
    {"name": "bill_cycle_type", "datatype": dbt.type_string()},
    {"name": "billing_period", "datatype": dbt.type_string()}, 
    {"name": "charge_model", "datatype": dbt.type_string()},
    {"name": "charge_type", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "default_quantity", "datatype": dbt.type_float()}, 
    {"name": "deferred_revenue_accounting_code_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "discount_class_id", "datatype": dbt.type_string()},
    {"name": "discount_level", "datatype": dbt.type_string()},
    {"name": "end_date_condition", "datatype": dbt.type_string()},
    {"name": "exclude_item_billing_from_revenue_accounting", "datatype": "boolean"},
    {"name": "exclude_item_booking_from_revenue_accounting", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "included_units", "datatype": dbt.type_float()},
    {"name": "is_stacked_discount", "datatype": "boolean"}, 
    {"name": "list_price_base", "datatype": dbt.type_string()},
    {"name": "max_quantity", "datatype": dbt.type_float()},
    {"name": "min_quantity", "datatype": dbt.type_float()},
    {"name": "name", "datatype": dbt.type_string()},  
    {"name": "product_id", "datatype": dbt.type_string()},
    {"name": "product_rate_plan_id", "datatype": dbt.type_string()},
    {"name": "specific_billing_period", "datatype": dbt.type_int()},  
    {"name": "tax_mode", "datatype": dbt.type_string()},
    {"name": "taxable", "datatype": "boolean"},
    {"name": "trigger_event", "datatype": dbt.type_string()},
    {"name": "uom", "datatype": dbt.type_string()},
    {"name": "up_to_periods", "datatype": dbt.type_int()},
    {"name": "up_to_periods_type", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "updated_date", "datatype": dbt.type_timestamp()}, 
    {"name": "use_discount_specific_accounting_code", "datatype": "boolean"}, 
    {"name": "weekly_bill_cycle_day", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
