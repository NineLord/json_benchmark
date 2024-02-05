#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(realpath "${SCRIPT_DIR}/..")
INPUT_DIR=$(realpath "${PROJECT_DIR}/input")
OUTPUT_DIR=$(realpath "${PROJECT_DIR}/output")
UTILS_DIR=$(realpath "${SCRIPT_DIR}/Utils")
CLEAN_COMPILE_DIR=$(realpath "${UTILS_DIR}/CleanCompile")
CLEAR_WORKSHEETS_DIR=$(realpath "${UTILS_DIR}/ClearWorksheets")
SUM_UP_RECORD_CPU_DIR=$(realpath "${UTILS_DIR}/SumUpRecordCpu")
RECORD_CPU_DIR=$(realpath "${UTILS_DIR}/RecordCpu")
TESTERS_DIR=$(realpath "${PROJECT_DIR}/../testers")
RUST_SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/rust_json_benchmark/target/release")
RUST_MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/rust_multi_json_benchmark/target/release")
GO_SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/go_json_benchmark/bin")
GO_MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/go_multi_json_benchmark/bin")
JAVA_SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_json_benchmark")
JAVA_MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/java_multi_json_benchmark")
NODE_SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_json_benchmark")
NODE_MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/node_multi_json_benchmark")
#endregion

#region Files
CLEAN_COMPILE_RUST=$(realpath "${CLEAN_COMPILE_DIR}/rust.sh")
CLEAN_COMPILE_GO=$(realpath "${CLEAN_COMPILE_DIR}/go.sh")
CLEAN_COMPILE_JAVA=$(realpath "${CLEAN_COMPILE_DIR}/java.sh")
CLEAN_COMPILE_NODE_JS=$(realpath "${CLEAN_COMPILE_DIR}/nodejs.sh")
CLEAN_COMPILE_BUN=$(realpath "${CLEAN_COMPILE_DIR}/bun.sh")

RECORD_CPU=$(realpath "${RECORD_CPU_DIR}/record.sh")

RUST_SINGLE_THREAD_CMD="./json_tester" # Shaked-TODO
RUST_MULTI_THREAD_CMD_SINGLE="./json_tester --single-thread -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
RUST_MULTI_THREAD_CMD="./json_tester -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
GO_SINGLE_THREAD_CMD="./jsonTester" # Shaked-TODO
GO_MULTI_THREAD_CMD="./jsonTester -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
JAVA_SINGLE_THREAD_CMD="mvn exec:java -Dexec.args=\"\"" # Shaked-TODO
JAVA_MULTI_THREAD_CMD="mvn exec:java -Dexec.args=\"-s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER\""
NODE_SINGLE_THREAD_CMD="npm run start" # Shaked-TODO
NODE_MULTI_THREAD_CMD="npm run start -- -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_SINGLE_THREAD_CMD="bun run start_bun" # Shaked-TODO
BUN_MULTI_THREAD_CMD="bun run start_bun -- -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
#endregion
#endregion

#region Helper methods
runMultiThreadTest() {
    LANG="$1"
    CONFIG="$2"
    TEST_COUNTER="$3"
    EXEC_DIR="$4"
    EXEC_CMD="$5"
    IS_SINGLE_THREAD_MODE="$6"

    RUST_MODE=null
    if [ "${IS_SINGLE_THREAD_MODE}" = true ]; then
        RUST_MODE="s"
    else
        RUST_MODE="m"
    fi

    CONFIG_FILE="config_${CONFIG}"
    FULL_PATH_CONFIG="${INPUT_DIR}/${CONFIG_FILE}.json"

    REPORT_FILE_NAME=null
    if [ "${LANG}" = "Rust" ]; then
        REPORT_FILE_NAME="report_${LANG}_${CONFIG_FILE}${RUST_MODE}"
    else
        REPORT_FILE_NAME="report_${LANG}_${CONFIG_FILE}"
    fi

    FULL_PATH_CSV="${OUTPUT_DIR}/${REPORT_FILE_NAME}.csv"
    FULL_PATH_XLSX="${OUTPUT_DIR}/${REPORT_FILE_NAME}.xlsx"

    echo "INFO :: Running ${LANG} Multi Thread Benchmark" >/dev/tty
    "${RECORD_CPU}" "${FULL_PATH_CSV}" 0>/dev/null 1>/dev/null 2>/dev/null &
    RECORD_CPU_PID=$!

    PREVIOUS_WORKING_DIR=$(pwd)
    cd "${EXEC_DIR}"
    EXEC=$(echo "${EXEC_CMD}" | sed -e 's/@FULL_PATH_XLSX/${FULL_PATH_XLSX}/g' -e 's/@FULL_PATH_CONFIG/${FULL_PATH_CONFIG}/g' -e 's/@TEST_COUNTER/${TEST_COUNTER}/g')
    eval "${EXEC}" 1>/dev/null 2>/dev/null
    cd "${PREVIOUS_WORKING_DIR}"

    kill "${RECORD_CPU_PID}"

    echo "INFO :: Fixing up report files for ${LANG} Multi Thread Benchmark" >/dev/tty
    node "${CLEAR_WORKSHEETS_DIR}" "${FULL_PATH_XLSX}" 1>/dev/null 2>/dev/null
    # node "${SUM_UP_RECORD_CPU_DIR}" 1>/dev/null 2>/dev/null # Shaked-TODO
}
#endregion

#region Making sure output directory is ready
echo "INFO :: Cleaning the output directory: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
#endregion

#region Benchmark Rust
: ' # Shaked-TODO: uncomment
"${CLEAN_COMPILE_RUST}"
runMultiThreadTest "Rust" 2 10000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" true
runMultiThreadTest "Rust" 2 10000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}" false

"${CLEAN_COMPILE_GO}"
runMultiThreadTest "Go" 2 10000 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_JAVA}"
runMultiThreadTest "Java" 2 10000 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_NODE_JS}"
runMultiThreadTest "NodeJs" 2 10000 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_BUN}"
runMultiThreadTest "Bun" 2 10000 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
'

runMultiThreadTest "Bun" 2 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"


#endregion