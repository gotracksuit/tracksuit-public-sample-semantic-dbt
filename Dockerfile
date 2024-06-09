ARG py_version=3.11.2

FROM python:$py_version-slim-bullseye as base

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20210119 \
    git=1:2.30.2-1+deb11u2 \
    libpq-dev=13.14-0+deb11u1 \
    make=4.3-4.1 \
    openssh-client=1:8.4p1-5+deb11u3 \
    software-properties-common=0.96.20.2-2.1 \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8


FROM base as dbt-core

HEALTHCHECK CMD dbt --version || exit 1

WORKDIR /usr/app/dbt/

RUN python -m pip install dbt-core==1.7.16 dbt-postgres==1.7.16


FROM dbt-core as dbt-metricflow

# Set the working directory
WORKDIR /usr/src/dbt

# Copy the project files into the container
COPY . .

RUN pip install protobuf==3.20.1
RUN pip install dbt-metricflow

# Install any additional dependencies if needed
# RUN pip install <dependencies>

# Set the entrypoint to run dbt
# ENTRYPOINT ["dbt"]
