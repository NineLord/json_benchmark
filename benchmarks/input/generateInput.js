const fs = require('fs');
const { resolve } = require('path');
const { spawnSync } = require('child_process');

const NUMBER_OF_CORES = 16;
const PATH_TO_JSON_GENERATOR = resolve(__dirname, '../../testers/rust_json_benchmark/target/release/json_generator');

/**
 * @param {string} name 
 * @param {number} numberOfLetters 
 * @param {number} depth 
 * @param {number} numberOfChildren 
 * @return {string}
 */
function generateJson(name, numberOfLetters, depth, numberOfChildren) {
    const absolutePathToOutputFile = resolve(__dirname, `${name}Json_n${numberOfLetters}_d${depth}_m${numberOfChildren}.json`);
    const result = spawnSync(`"${PATH_TO_JSON_GENERATOR}" -n${numberOfLetters} -d${depth} -m${numberOfChildren} "${absolutePathToOutputFile}"`, { shell: true });

    if (result.status !== 0)
        throw new Error(`Failed to generate JSON: ${result.stderr.toString()}`);

    return absolutePathToOutputFile;
}

/**
 * @typedef {object} Config
 * @property {string} name 
 * @property {string} size 
 * @property {string} path 
 * @property {number} numberOfLetters 
 * @property {number} depth 
 * @property {number} numberOfChildren 
 */

/**
 * @param {string} name 
 * @param {string} size 
 * @param {string} path 
 * @param {number} numberOfLetters 
 * @param {number} depth 
 * @param {number} numberOfChildren 
 * @return {Config}
 */
function generateConfig(name, size, path, numberOfLetters, depth, numberOfChildren) {
    return {
        name,
        size,
        path,
        numberOfLetters,
        depth,
        numberOfChildren
    };
}

/**
 * @param {number} amount 
 * @param {Config[]} configs
 * @param {string} fileName
 */
function generateConfigFile(amount, configs, fileName) {
    const config_file = [];
    for (let count = 0; count < amount; ++count) {
        for (const config of configs)
            config_file.push(config);
    }

    fs.writeFileSync(resolve(__dirname, fileName), JSON.stringify(config_file, null, 2));
}

const huge_n8_d10_m5 = generateJson('huge', 8, 10, 5);
const small_n8_d3_m8 = generateJson('small', 8, 3, 8);
const small_n8_d10_m3 = generateJson('small', 8, 10, 3);
const small_n8_d5_m3 = generateJson('small', 8, 5, 3);
const small_n8_d4_m6 = generateJson('small', 8, 4, 6);
const small_n8_d5_m5 = generateJson('small', 8, 5, 5);

const configLikePoliceman = generateConfig('LikePoliceman', '5.3K', small_n8_d5_m3, 8, 5, 3);
const configLikeCriminal = generateConfig('LikeCriminal', '8.5K', small_n8_d3_m8, 8, 3, 8);
const configBig = generateConfig('Big', '60K', small_n8_d5_m5, 8, 5, 5);
const configBiggest = generateConfig('Biggest', '1.2M', small_n8_d10_m3, 8, 10, 3);
const configMedium = generateConfig('Medium', '24K', small_n8_d4_m6, 8, 4, 6);

const config = [configLikePoliceman, configLikeCriminal];
generateConfigFile(Math.ceil((NUMBER_OF_CORES * 0.50) / 2), config, 'config_50.json');
config.push(configBig);
generateConfigFile(Math.ceil((NUMBER_OF_CORES * 0.75) / 3), config, 'config_75.json');
config.push(configBiggest);
generateConfigFile(Math.ceil((NUMBER_OF_CORES /* * 1.00 */) / 4), config, 'config_100.json');
config.push(configMedium);
generateConfigFile(Math.ceil((NUMBER_OF_CORES * 1.25) / 5), config, 'config_125.json');