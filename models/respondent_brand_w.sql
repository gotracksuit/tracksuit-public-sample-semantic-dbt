{{ config(materialized='view') }}

select * from {{ source('my_source', 'respondent_brand_w') }}
