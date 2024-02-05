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

echo "INFO :: Cleaning NodeJs Single Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
rm -rf node_modules

echo "INFO :: Cleaning NodeJs Multi Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
rm -rf node_modules

echo "INFO :: Compling NodeJs Single Thread"
cd "${SINGLE_THREAD_DIR}"
npm install --omit=dev

echo "INFO :: Compling NodeJs Multi Thread"
cd "${MULTI_THREAD_DIR}"
npm install --omit=dev