CREATE TABLE public.brand (
    id INT4 NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE public.ethnicity (
    id INT4 NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE public.respondent (
    id INT4 NOT NULL,
    wave_date DATE,
    weight FLOAT8,
    PRIMARY KEY (id)
);

CREATE TABLE public.respondent_brand (
    id SERIAL PRIMARY KEY,
    respondent_id INT4 NOT NULL,
    brand_id INT4 NOT NULL,
    FOREIGN KEY (respondent_id) REFERENCES public.respondent (id),
    FOREIGN KEY (brand_id) REFERENCES public.brand (id)
);

CREATE TABLE public.respondent_ethnicity (
    id SERIAL PRIMARY KEY,
    respondent_id INT4 NOT NULL,
    ethnicity_id INT4 NOT NULL,
    FOREIGN KEY (respondent_id) REFERENCES public.respondent (id),
    FOREIGN KEY (ethnicity_id) REFERENCES public.ethnicity (id)
);

COPY public.brand(id, name)
FROM '/var/lib/postgresql/new-data/brand.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY public.ethnicity(id, name)
FROM '/var/lib/postgresql/new-data/ethnicity.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY public.respondent(id, wave_date, weight)
FROM '/var/lib/postgresql/new-data/respondent.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY public.respondent_brand(respondent_id, brand_id)
FROM '/var/lib/postgresql/new-data/respondent_brand.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY public.respondent_ethnicity(respondent_id, ethnicity_id)
FROM '/var/lib/postgresql/new-data/respondent_ethnicity.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


CREATE VIEW public.vw_example_respondent_summary AS
WITH respondents AS (
    SELECT DISTINCT r.id AS respondent_id, r.weight, b.name AS brand_name
    FROM public.respondent r
    LEFT JOIN public.respondent_ethnicity re ON re.respondent_id = r.id
    LEFT JOIN public.ethnicity e ON e.id = re.ethnicity_id 
    LEFT JOIN public.respondent_brand rb ON rb.respondent_id = r.id
    LEFT JOIN public.brand b ON b.id = rb.brand_id 
    WHERE 
        e.name IN ('Ethnicity D','Ethnicity C') AND r.wave_date = '2023-08-01'
),
respondents_base AS (
    SELECT DISTINCT respondent_id, weight 
    FROM respondents
)
SELECT 
    brand_name, 
    SUM(r.weight) AS sum_weight,
    (SELECT SUM(weight) FROM respondents_base) AS total_weight,
    SUM(r.weight) / (SELECT SUM(weight) FROM respondents_base) AS percentage
FROM 
    respondents r
GROUP BY 
    brand_name
ORDER BY 
    brand_name ASC;


create or replace view respondent_brand_w as
select 
concat(r.id,'-',b.id) as id, r.id as respondent_id, 
b.id as brand_id, 
exists(select * from respondent_brand rb where rb.respondent_id = r.id and rb.brand_id = b.id) as matched, 
r.weight
from 
respondent r,
brand b ;

create schema public_dw;