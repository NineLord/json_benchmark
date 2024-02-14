#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_multi_json_benchmark")
#endregion

#region Files
BUN_SINGLE_LOCK_FILE=$(realpath -m "${SINGLE_THREAD_DIR}/bun.lockb")
NODE_SINGLE_LOCK_FILE=$(realpath -m "${SINGLE_THREAD_DIR}/package-lock.json")
BUN_MULTI_LOCK_FILE=$(realpath -m "${MULTI_THREAD_DIR}/bun.lockb")
NODE_MULTI_LOCK_FILE=$(realpath -m "${MULTI_THREAD_DIR}/package-lock.json")
#endregion

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
#endregion

echo -e "INFO :: Cleaning ${RED}Bun${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
rm -rf node_modules
rm -f "${BUN_SINGLE_LOCK_FILE}"
rm -f "${NODE_SINGLE_LOCK_FILE}"

echo -e "INFO :: Cleaning ${RED}Bun${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
rm -rf node_modules
rm -f "${BUN_MULTI_LOCK_FILE}"
rm -f "${NODE_MULTI_LOCK_FILE}"

# To make sure bluebird is remove:
# grep -rwn --color=always --exclude-dir="bluebird" bluebird . | grep require -C 1000

echo -e "$(date -u +%T.%3N) :: INFO :: Compling ${RED}Bun${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread"
cd "${SINGLE_THREAD_DIR}"
bun install
bun install --production
find ./node_modules/unzipper/lib -name "*.js" -exec sed -i -e "s/var Promise = require('bluebird');//g" {} \;

echo -e "$(date -u +%T.%3N) :: INFO :: Compling ${RED}Bun${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread"
cd "${MULTI_THREAD_DIR}"
bun install
bun install --production
find ./node_modules/unzipper/lib -name "*.js" -exec sed -i -e "s/var Promise = require('bluebird');//g" {} \;

# Shaked-TODO: add cleaning bun_node_modules