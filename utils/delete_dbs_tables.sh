#!/usr/bin/env bash

    dbs=("uc_pdm_source" "uc_pdm_transactional" "uc_pdm_transform" "uc_pdm_model" "uc_views_tables" "uc")
    declare -a $$dbs
    for db in "$${dbs[@]}"; do
      hive -e "DROP DATABASE $db cascade"
    done
