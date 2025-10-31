{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'zuora') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('zuora_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("zuora_database", target.database) }}' || '.'|| '{{ var("zuora_schema", "zuora") }}' as source_relation
{% endif %}

{%- endmacro %}