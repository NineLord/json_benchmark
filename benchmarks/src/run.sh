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

HUGE_JSON="hugeJson_n8_d10_m5"

RUST_SINGLE_THREAD_CMD="./json_tester -s @FULL_PATH_XLSX -n@NUMBER_OF_LETTERS -d@DEPTH -m@NUMBER_OF_CHILDREN -i@SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
RUST_MULTI_THREAD_CMD_SINGLE="./json_tester --single-thread -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
RUST_MULTI_THREAD_CMD="./json_tester -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
GO_SINGLE_THREAD_CMD="./jsonTester -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
GO_MULTI_THREAD_CMD="./jsonTester -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
JAVA_SINGLE_THREAD_CMD="MAVEN_OPTS=\"-Xmx8G -Xms16M -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20\" mvn exec:java -Dexec.args=\"@FULL_PATH_JSON @TEST_COUNTER @FULL_PATH_XLSX @NUMBER_OF_LETTERS @DEPTH @NUMBER_OF_CHILDREN @SAMPLING_INTERVAL\""
JAVA_MULTI_THREAD_CMD="MAVEN_OPTS=\"-Xmx8G -Xms16M -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20\" mvn exec:java -Dexec.args=\"-s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER\""
NODE_SINGLE_THREAD_CMD="npm run start -- @FULL_PATH_JSON @TEST_COUNTER -s @FULL_PATH_XLSX -n=@NUMBER_OF_LETTERS -d=@DEPTH -m=@NUMBER_OF_CHILDREN -i=@SAMPLING_INTERVAL"
NODE_MULTI_THREAD_CMD="npm run start -- -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_SINGLE_THREAD_CMD="bun run start_bun -- @FULL_PATH_JSON @TEST_COUNTER -s @FULL_PATH_XLSX -n=@NUMBER_OF_LETTERS -d=@DEPTH -m=@NUMBER_OF_CHILDREN -i=@SAMPLING_INTERVAL"
BUN_SINGLE_THREAD_CMD_LIMIT="bun run start_bun_limit -- @FULL_PATH_JSON @TEST_COUNTER -s @FULL_PATH_XLSX -n=@NUMBER_OF_LETTERS -d=@DEPTH -m=@NUMBER_OF_CHILDREN -i=@SAMPLING_INTERVAL"
BUN_MULTI_THREAD_CMD="bun run start_bun -- -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_MULTI_THREAD_CMD_LIMIT="bun run start_bun_limit -- -s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER"
#endregion

NUMBER_OF_CORES=16
#endregion

#region Helper methods
runSingleThreadTest() {
    LANG="${1}"
    JSON_FILE="${2}"
    TEST_COUNTER="${3}"
    NUMBER_OF_LETTERS="${4}"
    DEPTH="${5}"
    NUMBER_OF_CHILDREN="${6}"
    SAMPLING_INTERVAL="${7}"
    EXEC_DIR="${8}"
    EXEC_CMD="${9}"
    TEST_TYPE="${10}"

    FULL_PATH_JSON="${INPUT_DIR}/${JSON_FILE}.json"

    OUTPUT_DIR_NAME="normal"
    FILE_EXTENTION=""
    if [ "${TEST_TYPE}" != "" ]; then
        OUTPUT_DIR_NAME="${TEST_TYPE}"
        FILE_EXTENTION="_${TEST_TYPE}"
        TEST_TYPE=" - ${TEST_TYPE}"
    fi
    REPORT_FILE_NAME="report_${LANG}_${JSON_FILE}${FILE_EXTENTION}"

    FULL_PATH_OUTPUT="${OUTPUT_DIR}/Single/${LANG}/${JSON_FILE}/${OUTPUT_DIR_NAME}"
    mkdir -p "${FULL_PATH_OUTPUT}"
    FULL_PATH_CSV="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.csv"
    FULL_PATH_XLSX="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.xlsx"

    echo "INFO :: Running ${LANG} Single Thread Benchmark${TEST_TYPE} - json=${JSON_FILE} - testCounter=${TEST_COUNTER} - letters=${NUMBER_OF_LETTERS} - depth=${DEPTH} - children=${NUMBER_OF_CHILDREN} - interval=${SAMPLING_INTERVAL}" >/dev/tty
    "${RECORD_CPU}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 0>/dev/null 1>/dev/null 2>/dev/null &
    RECORD_CPU_PID=$!

    PREVIOUS_WORKING_DIR=$(pwd)
    cd "${EXEC_DIR}"
    EXEC=$(echo "${EXEC_CMD}" | sed \
        -e 's/@FULL_PATH_JSON/${FULL_PATH_JSON}/g' \
        -e 's/@TEST_COUNTER/${TEST_COUNTER}/g' \
        -e 's/@FULL_PATH_XLSX/${FULL_PATH_XLSX}/g' \
        -e 's/@NUMBER_OF_LETTERS/${NUMBER_OF_LETTERS}/g' \
        -e 's/@DEPTH/${DEPTH}/g' \
        -e 's/@NUMBER_OF_CHILDREN/${NUMBER_OF_CHILDREN}/g' \
        -e 's/@SAMPLING_INTERVAL/${SAMPLING_INTERVAL}/g' \
    )
    eval "${EXEC}" 1>/dev/null 2>/dev/null
    cd "${PREVIOUS_WORKING_DIR}"

    kill "${RECORD_CPU_PID}"

    echo "INFO :: Fixing up report files for ${LANG} Single Thread Benchmark${TEST_TYPE} - json=${JSON_FILE} - testCounter=${TEST_COUNTER} - letters=${NUMBER_OF_LETTERS} - depth=${DEPTH} - children=${NUMBER_OF_CHILDREN} - interval=${SAMPLING_INTERVAL}" >/dev/tty
    node "${CLEAR_WORKSHEETS_DIR}" "${FULL_PATH_XLSX}" 1>/dev/null 2>/dev/null
    node "${SUM_UP_RECORD_CPU_DIR}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 1>/dev/null 2>/dev/null
}

runMultiThreadTest() {
    LANG="${1}"
    CONFIG="${2}"
    TEST_COUNTER="${3}"
    EXEC_DIR="${4}"
    EXEC_CMD="${5}"
    TEST_TYPE="${6}"

    CONFIG_FILE="config_${CONFIG}"
    FULL_PATH_CONFIG="${INPUT_DIR}/${CONFIG_FILE}.json"

    OUTPUT_DIR_NAME="normal"
    FILE_EXTENTION=""
    if [ "${TEST_TYPE}" != "" ]; then
        OUTPUT_DIR_NAME="${TEST_TYPE}"
        FILE_EXTENTION="_${TEST_TYPE}"
        TEST_TYPE=" - ${TEST_TYPE}"
    fi
    REPORT_FILE_NAME="report_${LANG}_${CONFIG_FILE}${FILE_EXTENTION}"

    FULL_PATH_OUTPUT="${OUTPUT_DIR}/Multi/${LANG}/config_${CONFIG}/${OUTPUT_DIR_NAME}"
    mkdir -p "${FULL_PATH_OUTPUT}"
    FULL_PATH_CSV="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.csv"
    FULL_PATH_XLSX="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.xlsx"

    echo "INFO :: Running ${LANG} Multi Thread Benchmark${TEST_TYPE} - config=${CONFIG} - testCounter=${TEST_COUNTER}" >/dev/tty
    "${RECORD_CPU}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 0>/dev/null 1>/dev/null 2>/dev/null &
    RECORD_CPU_PID=$!

    PREVIOUS_WORKING_DIR=$(pwd)
    cd "${EXEC_DIR}"
    EXEC=$(echo "${EXEC_CMD}" | sed \
        -e 's/@FULL_PATH_XLSX/${FULL_PATH_XLSX}/g' \
        -e 's/@FULL_PATH_CONFIG/${FULL_PATH_CONFIG}/g' \
        -e 's/@TEST_COUNTER/${TEST_COUNTER}/g' \
    )
    eval "${EXEC}" 1>/dev/null 2>/dev/null
    cd "${PREVIOUS_WORKING_DIR}"

    kill "${RECORD_CPU_PID}"

    echo "INFO :: Fixing up report files for ${LANG} Multi Thread Benchmark${TEST_TYPE} - config=${CONFIG} - testCounter=${TEST_COUNTER}" >/dev/tty
    node "${CLEAR_WORKSHEETS_DIR}" "${FULL_PATH_XLSX}" 1>/dev/null 2>/dev/null
    node "${SUM_UP_RECORD_CPU_DIR}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 1>/dev/null 2>/dev/null
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
runSingleThreadTest "Rust" "${HUGE_JSON}" 5 8 10 5 10 "${RUST_SINGLE_THREAD_DIR}" "${RUST_SINGLE_THREAD_CMD}"
runMultiThreadTest "Rust" 2 10000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
runMultiThreadTest "Rust" 3 2000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
runMultiThreadTest "Rust" 4 100 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
runMultiThreadTest "Rust" 5 100 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"

runMultiThreadTest "Rust" 2 10000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"
runMultiThreadTest "Rust" 3 2000 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"
runMultiThreadTest "Rust" 4 100 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"
runMultiThreadTest "Rust" 5 100 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_GO}"
runSingleThreadTest "Go" "${HUGE_JSON}" 5 8 10 5 10 "${GO_SINGLE_THREAD_DIR}" "${GO_SINGLE_THREAD_CMD}"
runMultiThreadTest "Go" 2 10000 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"
runMultiThreadTest "Go" 3 2000 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"
runMultiThreadTest "Go" 4 100 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"
runMultiThreadTest "Go" 5 100 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_JAVA}"
runSingleThreadTest "Java" "${HUGE_JSON}" 5 8 10 5 10 "${JAVA_SINGLE_THREAD_DIR}" "${JAVA_SINGLE_THREAD_CMD}"
runMultiThreadTest "Java" 2 10000 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"
runMultiThreadTest "Java" 3 2000 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"
runMultiThreadTest "Java" 4 100 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"
runMultiThreadTest "Java" 5 100 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"

"${CLEAN_COMPILE_NODE_JS}"
runSingleThreadTest "NodeJs" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD}"
runMultiThreadTest "NodeJs" 2 10000 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"
runMultiThreadTest "NodeJs" 3 2000 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"
runMultiThreadTest "NodeJs" 4 100 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"
runMultiThreadTest "NodeJs" 5 100 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"

# Shaked-TODO: bun cant use worker_threads/workerpool, need to change the tests to support them.
"${CLEAN_COMPILE_BUN}"
runSingleThreadTest "Bun" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
runMultiThreadTest "Bun" 2 10000 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
runMultiThreadTest "Bun" 3 2000 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
runMultiThreadTest "Bun" 4 100 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
runMultiThreadTest "Bun" 5 100 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"

runSingleThreadTest "Bun" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_LIMIT}" "limit"
runMultiThreadTest "Bun" 2 10000 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
runMultiThreadTest "Bun" 3 2000 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
runMultiThreadTest "Bun" 4 100 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
runMultiThreadTest "Bun" 5 100 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
'

runMultiThreadTest "Rust" 2 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"
# runMultiThreadTest "Rust" 3 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"
# runMultiThreadTest "Rust" 2 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
# runMultiThreadTest "Rust" 3 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"

# "${CLEAN_COMPILE_BUN}"
# runMultiThreadTest "Bun" 2 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
# runMultiThreadTest "Bun" 3 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
# runMultiThreadTest "Bun" 2 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
# runMultiThreadTest "Bun" 3 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"

# runSingleThreadTest "NodeJs" "smallJson_n8_d3_m8" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD}"
# runSingleThreadTest "Go" "smallJson_n8_d3_m8" 2 2 2 2 50 "${GO_SINGLE_THREAD_DIR}" "${GO_SINGLE_THREAD_CMD}"
runSingleThreadTest "Rust" "smallJson_n8_d3_m8" 2 8 8 6 50 "${RUST_SINGLE_THREAD_DIR}" "${RUST_SINGLE_THREAD_CMD}"
# runSingleThreadTest "Java" "smallJson_n8_d3_m8" 2 2 2 2 50 "${JAVA_SINGLE_THREAD_DIR}" "${JAVA_SINGLE_THREAD_CMD}"
#endregion