#!/bin/bash
echo "Running dbt commands"
dbt run
dbt parse
mf query --metrics total_weight