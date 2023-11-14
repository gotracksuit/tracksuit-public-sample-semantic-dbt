-- Find the percentage of people that are aware of each brand, where that respondent has
-- an Ethnicity D or Ethnicity C in the month 2023-08-01. A respondent can be aware of many brands, and a respondent can have 
-- multiple ethnicities.
-- Find a way to express this kind of query with semantic layer.
with respondents as (
select distinct respondent_id,weight, brand_id 
from {{ ref('fact_respondent') }} fr
inner join {{ ref('dim_ethnicity') }} de on de.id = fr.ethnicity_id 
where 
de.name in ('Ethnicity D','Ethnicity C') and fr.wave_date = '2023-08-01'
),
respondents_base as (
select distinct respondent_id, weight 
from respondents
)
select 
db.name, 
sum(r.weight)/(select sum(weight) from respondents_base) as percentage
from 
respondents r
inner join {{ ref('dim_brand') }} db on r.brand_id = db.id 
group by 
db.name
order by 
db.name asc