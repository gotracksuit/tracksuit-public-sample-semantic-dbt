# Semantic Layer Modelling Problem

The intention of this repository is to build out a sample set of data that is a small representation of the kind of many-to-many issues that exist in the survey domain. You can run the example using the instructions below.

We want a semantic model which can generate a query like this:

```
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
```

From a model like this:

![alt text](image.png)

# Running the project with Docker

You'll first need to build and run the services via Docker (as defined in `docker-compose.yml`):

```bash
$ docker compose build
$ docker compose up
```

to destroy the db:

```bash
$ docker compose down
```

Connect to the database using your favourite SQL client on:

```
h: 127.0.0.1:5422
u: postgres
pwd: postgres
```

Connect to cube on: http://localhost:4000/#/

# Solution

Create a new version of respondent_brand, which is a cross product of all respondents and brands, keep a column to mark which ones are fillers, then use this as a filter on the measures. Also pull up the weight value from respondent.

```
create or replace view respondent_brand_w as
select concat(r.id,'-',b.id) as id, r.id as respondent_id, b.id as brand_id, exists(select * from respondent_brand rb where rb.respondent_id = r.id and rb.brand_id = b.id) as matched, r.weight
from
respondent r,
brand b
```

Use the respondent_brand cube as the base, rather than the respondent cube (this is why we brought up the weight value earlier).

Run this query to generate the correct results:

```
{
    "order": {
        "respondent.weight": "desc"
    },
    "filters": [
        {
            "member": "ethnicity.name",
            "operator": "equals",
            "values": [
                "Ethnicity D",
                "Ethnicity C"
            ]
        },
        {
            "member": "respondent.wave_date",
            "operator": "equals",
            "values": [
                "'2023-08-01'"
            ]
        }
    ],
    "dimensions": [
        "brand.name"
    ],
    "timeDimensions": [
        {
            "dimension": "respondent.wave_date"
        }
    ],
    "measures": [
        "respondent_brand.weight",
        "respondent_brand.base_weight",
        "respondent_brand.brand_percentage"
    ]
}
```
