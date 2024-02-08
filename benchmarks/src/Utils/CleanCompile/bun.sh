#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_multi_json_benchmark")
#endregion
#endregion

echo "INFO :: Cleaning Bun Single Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
rm -rf node_modules

echo "INFO :: Cleaning Bun Multi Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
rm -rf node_modules

# To make sure bluebird is remove:
# grep -rwn --color=always --exclude-dir="bluebird" bluebird . | grep require -C 1000

echo "INFO :: Compling Bun Single Thread"
cd "${SINGLE_THREAD_DIR}"
bun install --production
find ./node_modules/unzipper/lib -name "*.js" -exec sed -i -e "s/var Promise = require('bluebird');//g" {} \;

echo "INFO :: Compling Bun Multi Thread"
cd "${MULTI_THREAD_DIR}"
bun install --production
find ./node_modules/unzipper/lib -name "*.js" -exec sed -i -e "s/var Promise = require('bluebird');//g" {} \;