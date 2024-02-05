#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_multi_json_benchmark")
MAVEN_LOCAL_REPOSITORY=$(realpath "~/.m2")
#endregion
#endregion

echo "INFO :: Cleaning Java Downloaded Packages"
rm -rf "${MAVEN_LOCAL_REPOSITORY}"

echo "INFO :: Cleaning Java Single Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
mvn -U clean

echo "INFO :: Cleaning Java Multi Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
mvn -U clean

echo "INFO :: Compling Java Single Thread"
cd "${SINGLE_THREAD_DIR}"
mvn compile

echo "INFO :: Compling Java Multi Thread"
cd "${MULTI_THREAD_DIR}"
mvn compile