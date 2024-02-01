#!/bin/bash
set -e # Will exit on the first line that exited with none zero exit code

#region Imports
#region Directories
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TESTERS_DIR=$(realpath "${SCRIPT_DIR}/../../../../testers")
SINGLE_THREAD_DIR=$(realpath "${TESTERS_DIR}/rust_json_benchmark")
MULTI_THREAD_DIR=$(realpath "${TESTERS_DIR}/rust_multi_json_benchmark")
#endregion
#endregion

echo "INFO :: Cleaning Rust Single Thread Compiled Data"
cd "${SINGLE_THREAD_DIR}"
cargo clean

echo "INFO :: Cleaning Rust Multi Thread Compiled Data"
cd "${MULTI_THREAD_DIR}"
cargo clean

echo "INFO :: Compling Rust Single Thread"
cd "${SINGLE_THREAD_DIR}"
cargo build --bin json_tester --release

echo "INFO :: Compling Rust Multi Thread"
cd "${MULTI_THREAD_DIR}"
cargo build --bin json_tester --release