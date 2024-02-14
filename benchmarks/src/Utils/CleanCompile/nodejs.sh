#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_multi_json_benchmark")
#endregion

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
#endregion

echo -e "INFO :: Cleaning ${RED}NodeJs${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
rm -rf node_modules

echo -e "INFO :: Cleaning ${RED}NodeJs${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
rm -rf node_modules

echo -e "$(date -u +%T.%3N) :: INFO :: Compling ${RED}NodeJs${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread"
cd "${SINGLE_THREAD_DIR}"
npm install --omit=dev

echo -e "$(date -u +%T.%3N) :: INFO :: Compling ${RED}NodeJs${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread"
cd "${MULTI_THREAD_DIR}"
npm install --omit=dev

# Shaked-TODO: add cleaning bun_node_modules