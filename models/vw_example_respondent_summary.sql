{{ config(materialized='view') }}

select * from {{ source('my_source', 'vw_example_respondent_summary') }}
