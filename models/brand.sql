{{ config(materialized='table') }}

select * from {{ source('my_source', 'brand') }}
