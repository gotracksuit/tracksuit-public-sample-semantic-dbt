{{ config(materialized='table') }}

select * from {{ source('my_source', 'respondent_ethnicity') }}
