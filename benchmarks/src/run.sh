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
RUST_SINGLE_THREAD_DIR_MAIN=$(realpath "${TESTERS_DIR}/rust_json_benchmark")
RUST_SINGLE_THREAD_DIR=$(realpath -m "${RUST_SINGLE_THREAD_DIR_MAIN}/target/release")
RUST_MULTI_THREAD_DIR_MAIN=$(realpath "${TESTERS_DIR}/rust_multi_json_benchmark")
RUST_MULTI_THREAD_DIR=$(realpath -m "${RUST_MULTI_THREAD_DIR_MAIN}/target/release")
GO_SINGLE_THREAD_DIR_MAIN=$(realpath "${TESTERS_DIR}/go_json_benchmark")
GO_SINGLE_THREAD_DIR=$(realpath -m "${GO_SINGLE_THREAD_DIR_MAIN}/bin")
GO_MULTI_THREAD_DIR_MAIN=$(realpath "${TESTERS_DIR}/go_multi_json_benchmark")
GO_MULTI_THREAD_DIR=$(realpath -m "${GO_MULTI_THREAD_DIR_MAIN}/bin")
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
RUST_MULTI_THREAD_CMD_SINGLE="./json_tester --single-thread -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
RUST_MULTI_THREAD_CMD="./json_tester -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
GO_SINGLE_THREAD_CMD="./jsonTester -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
GO_MULTI_THREAD_CMD="./jsonTester -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
JAVA_SINGLE_THREAD_CMD="MAVEN_OPTS=\"-Xmx8G -Xms16M -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20\" mvn exec:java -Dexec.args=\"@FULL_PATH_JSON @TEST_COUNTER @FULL_PATH_XLSX @NUMBER_OF_LETTERS @DEPTH @NUMBER_OF_CHILDREN @SAMPLING_INTERVAL\""
JAVA_MULTI_THREAD_CMD="MAVEN_OPTS=\"-Xmx8G -Xms16M -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20\" mvn exec:java -Dexec.args=\"-s @FULL_PATH_XLSX @FULL_PATH_CONFIG @TEST_COUNTER @NUMBER_OF_THREADS\""
NODE_SINGLE_THREAD_CMD="npm run start -- -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
NODE_SINGLE_THREAD_CMD_BUN_RECORDER="npm run start_bun_recorder -- -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
NODE_MULTI_THREAD_CMD="npm run start -- -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
NODE_MULTI_THREAD_CMD_BUN_POOL="npm run start_bun_pool -- -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_SINGLE_THREAD_CMD="bun run start_bun -- -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
BUN_SINGLE_THREAD_CMD_LIMIT="bun run start_bun_limit -- -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
BUN_SINGLE_THREAD_CMD_BIG_LIMIT="bun run start_bun_big_limit -- -s @FULL_PATH_XLSX -n @NUMBER_OF_LETTERS -d @DEPTH -m @NUMBER_OF_CHILDREN -i @SAMPLING_INTERVAL @FULL_PATH_JSON @TEST_COUNTER"
BUN_MULTI_THREAD_CMD="bun run start_bun -- -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_MULTI_THREAD_CMD_LIMIT="bun run start_bun_limit -- -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
BUN_MULTI_THREAD_CMD_BIG_LIMIT="bun run start_bun_big_limit -- -s @FULL_PATH_XLSX -t @NUMBER_OF_THREADS @FULL_PATH_CONFIG @TEST_COUNTER"
#endregion

#region Test Settings
NUMBER_OF_CORES=16
NUMBER_OF_THREADS=15

#region Single Thread Test
SINGLE_JSON="${HUGE_JSON}"
SINGLE_TEST_COUNTER=5
SINGLE_NUMBER_OF_LETTERS=8
SINGLE_DEPTH=10
SINGLE_NUMBER_OF_CHILDREN=5
SINGLE_SAMPLING_INTERVAL=10
#endregion

#region Multi Thread Test
MULTI_50_CONFIG=2 # 8
MULTI_50_TEST_COUNTER=10000

MULTI_75_CONFIG=3 # 12
MULTI_75_TEST_COUNTER=2000

MULTI_100_CONFIG=4 # 16
MULTI_100_TEST_COUNTER=100

MULTI_125_CONFIG=5 # 20
MULTI_125_TEST_COUNTER=100
#endregion
#endregion

RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"
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
        TEST_TYPE=" - ${CYAN}${TEST_TYPE}${ENDCOLOR}"
    fi
    REPORT_FILE_NAME="report_${LANG}_${JSON_FILE}${FILE_EXTENTION}"

    FULL_PATH_OUTPUT="${OUTPUT_DIR}/Single/${LANG}/${JSON_FILE}/${OUTPUT_DIR_NAME}"
    mkdir -p "${FULL_PATH_OUTPUT}"
    FULL_PATH_CSV="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.csv"
    FULL_PATH_XLSX="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.xlsx"

    echo -e "$(date -u +%T.%3N) :: INFO :: Running ${RED}${LANG}${ENDCOLOR} ${GREEN}Single${ENDCOLOR} Thread Benchmark${TEST_TYPE} - json=${JSON_FILE} - testCounter=${TEST_COUNTER} - letters=${NUMBER_OF_LETTERS} - depth=${DEPTH} - children=${NUMBER_OF_CHILDREN} - interval=${SAMPLING_INTERVAL}" >/dev/tty
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

    echo "$(date -u +%T.%3N) :: INFO :: Fixing up report files" >/dev/tty
    node "${CLEAR_WORKSHEETS_DIR}" "${FULL_PATH_XLSX}" 1>/dev/null 2>/dev/null
    node "${SUM_UP_RECORD_CPU_DIR}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 1>/dev/null 2>/dev/null
}

setupSingleThreadTest() {
    SETUP_SINGLE_LANG="${1}"
    SETUP_SINGLE_JSON_FILE="${SINGLE_JSON}"
    SETUP_SINGLE_TEST_COUNTER="${SINGLE_TEST_COUNTER}"
    SETUP_SINGLE_NUMBER_OF_LETTERS="${SINGLE_NUMBER_OF_LETTERS}"
    SETUP_SINGLE_DEPTH="${SINGLE_DEPTH}"
    SETUP_SINGLE_NUMBER_OF_CHILDREN="${SINGLE_NUMBER_OF_CHILDREN}"
    SETUP_SINGLE_SAMPLING_INTERVAL="${SINGLE_SAMPLING_INTERVAL}"
    SETUP_SINGLE_EXEC_DIR="${2}"
    SETUP_SINGLE_EXEC_CMD="${3}"
    SETUP_SINGLE_TEST_TYPE="${4}"

    runSingleThreadTest "${SETUP_SINGLE_LANG}" "${SETUP_SINGLE_JSON_FILE}" \
        "${SETUP_SINGLE_TEST_COUNTER}" "${SETUP_SINGLE_NUMBER_OF_LETTERS}" \
        "${SETUP_SINGLE_DEPTH}" "${SETUP_SINGLE_NUMBER_OF_CHILDREN}" \
        "${SETUP_SINGLE_SAMPLING_INTERVAL}" "${SETUP_SINGLE_EXEC_DIR}" \
        "${SETUP_SINGLE_EXEC_CMD}" "${SETUP_SINGLE_TEST_TYPE}"
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
        TEST_TYPE=" - ${CYAN}${TEST_TYPE}${ENDCOLOR}"
    fi
    REPORT_FILE_NAME="report_${LANG}_${CONFIG_FILE}${FILE_EXTENTION}"

    FULL_PATH_OUTPUT="${OUTPUT_DIR}/Multi/${LANG}/config_${CONFIG}/${OUTPUT_DIR_NAME}"
    mkdir -p "${FULL_PATH_OUTPUT}"
    FULL_PATH_CSV="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.csv"
    FULL_PATH_XLSX="${FULL_PATH_OUTPUT}/${REPORT_FILE_NAME}.xlsx"

    echo -e "$(date -u +%T.%3N) :: INFO :: Running ${RED}${LANG}${ENDCOLOR} ${GREEN}Multi${ENDCOLOR} Thread Benchmark${TEST_TYPE} - config=${CONFIG} - testCounter=${TEST_COUNTER}" >/dev/tty
    "${RECORD_CPU}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 0>/dev/null 1>/dev/null 2>/dev/null &
    RECORD_CPU_PID=$!

    PREVIOUS_WORKING_DIR=$(pwd)
    cd "${EXEC_DIR}"
    EXEC=$(echo "${EXEC_CMD}" | sed \
        -e 's/@FULL_PATH_XLSX/${FULL_PATH_XLSX}/g' \
        -e 's/@FULL_PATH_CONFIG/${FULL_PATH_CONFIG}/g' \
        -e 's/@TEST_COUNTER/${TEST_COUNTER}/g' \
        -e 's/@NUMBER_OF_THREADS/${NUMBER_OF_THREADS}/g' \
    )
    eval "${EXEC}" 1>/dev/null 2>/dev/null
    cd "${PREVIOUS_WORKING_DIR}"

    kill "${RECORD_CPU_PID}"

    echo "$(date -u +%T.%3N) :: INFO :: Fixing up report files" >/dev/tty
    node "${CLEAR_WORKSHEETS_DIR}" "${FULL_PATH_XLSX}" 1>/dev/null 2>/dev/null
    node "${SUM_UP_RECORD_CPU_DIR}" "${FULL_PATH_CSV}" "${NUMBER_OF_CORES}" 1>/dev/null 2>/dev/null
}

setupMultiThreadTest() {
    SETUP_MULTI_LANG="${1}"
    SETUP_MULTI_CONFIG="${MULTI_50_CONFIG}"
    SETUP_MULTI_TEST_COUNTER="${MULTI_50_TEST_COUNTER}"
    SETUP_MULTI_EXEC_DIR="${2}"
    SETUP_MULTI_EXEC_CMD="${3}"
    SETUP_MULTI_TEST_TYPE="${4}"
    runMultiThreadTest "${SETUP_MULTI_LANG}" "${SETUP_MULTI_CONFIG}" \
        "${SETUP_MULTI_TEST_COUNTER}" "${SETUP_MULTI_EXEC_DIR}" \
        "${SETUP_MULTI_EXEC_CMD}" "${SETUP_MULTI_TEST_TYPE}"

    SETUP_MULTI_CONFIG="${MULTI_75_CONFIG}"
    SETUP_MULTI_TEST_COUNTER="${MULTI_75_TEST_COUNTER}"
    runMultiThreadTest "${SETUP_MULTI_LANG}" "${SETUP_MULTI_CONFIG}" \
        "${SETUP_MULTI_TEST_COUNTER}" "${SETUP_MULTI_EXEC_DIR}" \
        "${SETUP_MULTI_EXEC_CMD}" "${SETUP_MULTI_TEST_TYPE}"

    SETUP_MULTI_CONFIG="${MULTI_100_CONFIG}"
    SETUP_MULTI_TEST_COUNTER="${MULTI_100_TEST_COUNTER}"
    runMultiThreadTest "${SETUP_MULTI_LANG}" "${SETUP_MULTI_CONFIG}" \
        "${SETUP_MULTI_TEST_COUNTER}" "${SETUP_MULTI_EXEC_DIR}" \
        "${SETUP_MULTI_EXEC_CMD}" "${SETUP_MULTI_TEST_TYPE}"

    SETUP_MULTI_CONFIG="${MULTI_125_CONFIG}"
    SETUP_MULTI_TEST_COUNTER="${MULTI_125_TEST_COUNTER}"
    runMultiThreadTest "${SETUP_MULTI_LANG}" "${SETUP_MULTI_CONFIG}" \
        "${SETUP_MULTI_TEST_COUNTER}" "${SETUP_MULTI_EXEC_DIR}" \
        "${SETUP_MULTI_EXEC_CMD}" "${SETUP_MULTI_TEST_TYPE}"
}
#endregion

#region Making sure output directory is ready
echo "$(date -u +%T.%3N) :: INFO :: Cleaning the output directory: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
#endregion

#region Short Benchmark
# "${CLEAN_COMPILE_RUST}"
# runSingleThreadTest "Rust" "smallJson_n8_d3_m8" 2 2 2 2 50 "${RUST_SINGLE_THREAD_DIR}" "${RUST_SINGLE_THREAD_CMD}"
# runMultiThreadTest "Rust" 2 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
# runMultiThreadTest "Rust" 2 2 "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_GO}"
# runSingleThreadTest "Go" "smallJson_n8_d3_m8" 2 2 2 2 50 "${GO_SINGLE_THREAD_DIR}" "${GO_SINGLE_THREAD_CMD}"
# runMultiThreadTest "Go" 2 2 "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_JAVA}"
# runSingleThreadTest "Java" "smallJson_n8_d3_m8" 2 2 2 2 50 "${JAVA_SINGLE_THREAD_DIR}" "${JAVA_SINGLE_THREAD_CMD}"
# runMultiThreadTest "Java" 2 2 "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_NODE_JS}"
# runSingleThreadTest "NodeJs" "smallJson_n8_d3_m8" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD}"
# runSingleThreadTest "NodeJs" "smallJson_n8_d3_m8" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD_BUN_RECORDER}" "BunRecorder"
# runMultiThreadTest "NodeJs" 2 2 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"
# runMultiThreadTest "NodeJs" 2 2 "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD_BUN_POOL}" "BunPool"

# "${CLEAN_COMPILE_BUN}"
# runSingleThreadTest "Bun" "smallJson_n8_d3_m8" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
# runSingleThreadTest "Bun" "${HUGE_JSON}" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
# runSingleThreadTest "Bun" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
# runSingleThreadTest "Bun" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_LIMIT}" "limit"
# runSingleThreadTest "Bun" "${HUGE_JSON}" 5 8 10 5 10 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_BIG_LIMIT}" "bigLimit"

# runSingleThreadTest "Bun" "smallJson_n8_d3_m8" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
# runMultiThreadTest "Bun" 2 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
# runSingleThreadTest "Bun" "smallJson_n8_d3_m8" 2 2 2 2 50 "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_LIMIT}" "limit"
# runMultiThreadTest "Bun" 2 2 "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
#endregion

#region Full Benchmark
# "${CLEAN_COMPILE_BUN}"
#region Always skipping those tests, it takes more than 15 minute for single thread test, at this point there is not reason to run them. TOO SLOW
# setupSingleThreadTest "Bun" "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD}"
# setupMultiThreadTest "Bun" "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD}"
#endregion
# setupSingleThreadTest "Bun" "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_LIMIT}" "limit"
# setupMultiThreadTest "Bun" "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_LIMIT}" "limit"
# setupSingleThreadTest "Bun" "${NODE_SINGLE_THREAD_DIR}" "${BUN_SINGLE_THREAD_CMD_BIG_LIMIT}" "bigLimit"
# setupMultiThreadTest "Bun" "${NODE_MULTI_THREAD_DIR}" "${BUN_MULTI_THREAD_CMD_BIG_LIMIT}" "bigLimit"

# "${CLEAN_COMPILE_RUST}"
# setupSingleThreadTest "Rust" "${RUST_SINGLE_THREAD_DIR}" "${RUST_SINGLE_THREAD_CMD}"
# setupMultiThreadTest "Rust" "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD_SINGLE}" "single"
# setupMultiThreadTest "Rust" "${RUST_MULTI_THREAD_DIR}" "${RUST_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_GO}"
# setupSingleThreadTest "Go" "${GO_SINGLE_THREAD_DIR}" "${GO_SINGLE_THREAD_CMD}"
# setupMultiThreadTest "Go" "${GO_MULTI_THREAD_DIR}" "${GO_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_JAVA}"
# setupSingleThreadTest "Java" "${JAVA_SINGLE_THREAD_DIR}" "${JAVA_SINGLE_THREAD_CMD}"
# setupMultiThreadTest "Java" "${JAVA_MULTI_THREAD_DIR}" "${JAVA_MULTI_THREAD_CMD}"

# "${CLEAN_COMPILE_NODE_JS}"
# setupSingleThreadTest "NodeJs" "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD}"
# setupMultiThreadTest "NodeJs" "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD}"
# setupSingleThreadTest "NodeJs" "${NODE_SINGLE_THREAD_DIR}" "${NODE_SINGLE_THREAD_CMD_BUN_RECORDER}" "BunRecorder"
# setupMultiThreadTest "NodeJs" "${NODE_MULTI_THREAD_DIR}" "${NODE_MULTI_THREAD_CMD_BUN_POOL}" "BunPool"
#endregion