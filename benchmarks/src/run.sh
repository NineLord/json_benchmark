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
#endregion

#region Files
CLEAN_COMPILE_RUST=$(realpath "${CLEAN_COMPILE_DIR}/rust.sh")
CLEAN_COMPILE_GO=$(realpath "${CLEAN_COMPILE_DIR}/go.sh")
CLEAN_COMPILE_JAVA=$(realpath "${CLEAN_COMPILE_DIR}/java.sh")
CLEAN_COMPILE_NODE_JS=$(realpath "${CLEAN_COMPILE_DIR}/nodejs.sh")
CLEAN_COMPILE_BUN=$(realpath "${CLEAN_COMPILE_DIR}/bun.sh")

RECORD_CPU=$(realpath "${RECORD_CPU_DIR}/record.sh")

RUST_SINGLE_THREAD=$(realpath "${TESTERS_DIR}/rust_json_benchmark/target/release/json_tester")
RUST_MULTI_THREAD=$(realpath "${TESTERS_DIR}/rust_multi_json_benchmark/target/release/json_tester")
GO_SINGLE_THREAD=$(realpath "${TESTERS_DIR}/go_json_benchmark/bin/jsonTester")
GO_MULTI_THREAD=$(realpath "${TESTERS_DIR}/go_multi_json_benchmark/bin/jsonTester")
#endregion
#endregion

#region Helper methods
runMultiThreadTest() {
    LANG="$1"
    CONFIG="$2"
    TESTER="$3"
    TEST_COUNTER="$4"
    IS_SINGLE_THREAD_MODE="$5"

    RUST_MODE=null
    RUST_FLAG=null
    if [ "${IS_SINGLE_THREAD_MODE}" = true ]; then
        RUST_MODE="s"
        RUST_FLAG="--single-thread"
    else
        RUST_MODE="m"
        RUST_FLAG=""
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

    if [ "${IS_SINGLE_THREAD_MODE}" = true ]; then
        "${TESTER}" --single-thread -s "${FULL_PATH_XLSX}" "${FULL_PATH_CONFIG}" "${TEST_COUNTER}"
    else
        "${TESTER}" -s "${FULL_PATH_XLSX}" "${FULL_PATH_CONFIG}" "${TEST_COUNTER}"
    fi

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
runMultiThreadTest "Rust" 2 "${RUST_MULTI_THREAD}" 10000 true

"${CLEAN_COMPILE_GO}"
runMultiThreadTest "Go" 2 "${GO_MULTI_THREAD}" 10000
'

# "${CLEAN_COMPILE_JAVA}" # Shaked-TODO: uncomment
# "${CLEAN_COMPILE_NODE_JS}" # Shaked-TODO: uncomment
# "${CLEAN_COMPILE_BUN}" # Shaked-TODO: uncomment
#endregion