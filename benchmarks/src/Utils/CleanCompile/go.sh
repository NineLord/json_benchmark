#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/go_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/go_multi_json_benchmark")
#endregion
#endregion

echo "INFO :: Cleaning Go Single Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
make clean

echo "INFO :: Cleaning Go Multi Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
make clean

echo "INFO :: Compling Go Single Thread"
cd "${SINGLE_THREAD_DIR}"
make release

echo "INFO :: Compling Go Multi Thread"
cd "${MULTI_THREAD_DIR}"
make release