# JSON Benchmark

This project is for running the following benchmark projects all at once:

- [node_json_benchmark](https://github.com/NineLord/node_json_benchmark).
- [node_multi_json_benchmark](https://github.com/NineLord/node_multi_json_benchmark).
- [java_json_benchmark](https://github.com/NineLord/java_json_benchmark).
- [java_multi_json_benchmark](https://github.com/NineLord/java_multi_json_benchmark).
- [go_json_benchmark](https://github.com/NineLord/go_json_benchmark).
- [go_multi_json_benchmark](https://github.com/NineLord/go_multi_json_benchmark).
- [rust_json_benchmark](https://github.com/NineLord/rust_json_benchmark).
- [rust_multi_json_benchmark](https://github.com/NineLord/rust_multi_json_benchmark).

## How to run it

### Setup (Need to do this once)

1. Git clone this project.
2. Git clone each of the above benchmark projects into the `testers` directory.
3. Build the `json_generator` from the `rust_json_benchmark` project, like so:
```shell
cd "./json_benchmark/testers/rust_json_benchmark"
cargo build --bin json_generator --release
```
4. Run the `generateInput.js` file in the `input` directory, like so:
```shell
cd "./json_benchmark/benchmarks/input"
node ./generateInput.js
```

### Run the tests

1. Run the `run.sh` file in the `src` directory, like so:
```shell
cd "./json_benchmark/benchmarks/src"
./run.sh
```
2. The results will wait for you in the `./json_benchmark/benchmarks/output` directory.  
   **Note**: If you run the tests again, the previous output will be overwritten, back it up if you need it!