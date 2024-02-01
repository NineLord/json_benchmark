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
#endregion
#endregion

#region Making sure output directory is ready
echo "INFO :: Cleaning the output directory: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
#endregion

#region Benchmark Rust
# "${CLEAN_COMPILE_RUST}" # Shaked-TODO: uncomment this

"${RECORD_CPU}" "${OUTPUT_DIR}/report_rust_2m.csv" &
RECORD_CPU_PID=$!

"${RUST_MULTI_THREAD}" -s "${OUTPUT_DIR}/report_rust_2m.xlsx" "${INPUT_DIR}/config_2.json" 2

kill "${RECORD_CPU_PID}"
node "${PATH_TO_CLEAR_WORKSHEET}" "${PATH_TO_OUTPUT_DIR}/report_rust_2m.xlsx"
#endregion