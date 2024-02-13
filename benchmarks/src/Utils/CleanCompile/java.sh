#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_multi_json_benchmark")
MAVEN_LOCAL_REPOSITORY=$(realpath -m "~/.m2")
#endregion

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"
#endregion

echo -e "INFO :: Cleaning Java Downloaded Packages"
rm -rf "${MAVEN_LOCAL_REPOSITORY}"

echo -e "INFO :: Cleaning ${RED}Java${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
mvn -U clean

echo -e "INFO :: Cleaning ${RED}Java${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
mvn -U clean

echo -e "INFO :: Compling ${RED}Java${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread"
cd "${SINGLE_THREAD_DIR}"
mvn compile

echo -e "INFO :: Compling ${RED}Java${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread"
cd "${MULTI_THREAD_DIR}"
mvn compile