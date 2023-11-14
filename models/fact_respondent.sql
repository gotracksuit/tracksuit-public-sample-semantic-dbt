select r.respondent_id, r.weight, r.wave_date, b.brand_id, e.ethnicity_id
from 
{{ ref('raw_respondent') }} r
left join {{ ref('raw_respondent_brand') }} b on b.respondent_id = r.respondent_id
left join  {{ ref('raw_respondent_ethnicity') }} e on e.respondent_id = r.respondent_id
