# Semantic Layer Modelling Problem

The intention of this repository is to build out a sample set of data that is a small representation of the kind of many-to-many issues that exist in the survey domain. You can run the example using the instructions below, then inspect the example view/model to get an idea of the kind of query that we would like the semantic layer to handle (in a much more elegant way).

# Running the project with Docker

You'll first need to build and run the services via Docker (as defined in `docker-compose.yml`):

```bash
$ docker compose build
$ docker compose up
```

or to run without blocking

```bash
$ docker compose up -d
```

The commands above will run a Postgres instance and then build the dbt resources of Jaffle Shop as specified in the
repository. These containers will remain up and running so that you can:

- Query the Postgres database and the tables created out of dbt models
- Run further dbt commands via dbt CLI

## Building additional or modified data models

Once the containers are up and running, you can still make any modifications in the existing dbt project
and re-run any command to serve the purpose of the modifications.

In order to build your data models, you first need to access the container.

To do so, we infer the container id for `dbt` running container:

```bash
docker ps
```

Then enter the running container:

```bash
docker exec -it <container-id> /bin/bash
```

And finally:

```bash
# Install dbt deps (might not required as long as you have no -or empty- `dbt_packages.yml` file)
dbt deps

# Build seeds
dbt seeds --profiles-dir profiles

# Build data models
dbt run --profiles-dir profiles

# Build snapshots
dbt snapshot --profiles-dir profiles

# Run tests
dbt test --profiles-dir profiles
```

Alternatively, you can run everything in just a single command:

```bash
dbt build --profiles-dir profiles
```

## Querying Jaffle Shop data models on Postgres

In order to query and verify the seeds, models and snapshots created in the dummy dbt project, simply follow the
steps below.

Connect to the database using your favourite SQL client on

h: 127.0.0.1:5422
u: postgres
pwd: postgres
