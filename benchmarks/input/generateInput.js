const fs = require('fs');
const { resolve } = require('path');
const { spawnSync } = require('child_process');

const PATH_TO_JSON_GENERATOR = resolve(__dirname, '../../testers/rust_json_benchmark/target/release/json_generator');

/**
 * @param {string} name 
 * @param {number} numberOfLetters 
 * @param {number} depth 
 * @param {number} numberOfChildren 
 * @return {string}
 */
function generateJson(name, numberOfLetters, depth, numberOfChildren) {
    const absolutePathToOutputFile = resolve(__dirname, `${name}Json_numberOfLetters${numberOfLetters}_depth${depth}_children${numberOfChildren}.json`);
    const result = spawnSync(`${PATH_TO_JSON_GENERATOR} -n${numberOfLetters} -d${depth} -m${numberOfChildren} ${absolutePathToOutputFile}`, { shell: true });

    if (result.status !== 0)
        throw new Error(`Failed to generate JSON: ${result.stderr.toString()}`);

    return absolutePathToOutputFile;
}

/**
 * @param {string} name 
 * @param {string} size 
 * @param {string} path 
 * @param {number} numberOfLetters 
 * @param {number} depth 
 * @param {number} numberOfChildren 
 * @return {{name: string, size: string, path: string, numberOfLetters: number, depth: number, numberOfChildren: number}}
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

const huge_n8_d10_m5 = generateJson('huge', 8, 10, 5);

const small_n8_d3_m8 = generateJson('small', 8, 3, 8);
const small_n8_d10_m3 = generateJson('small', 8, 10, 3);

const small_n8_d5_m3 = generateJson('small', 8, 5, 3);
const small_n8_d4_m6 = generateJson('small', 8, 4, 6);

const small_n8_d5_m5 = generateJson('small', 8, 5, 5);

const config = [
    generateConfig('LikePoliceman', '5.3K', small_n8_d5_m3, 8, 5, 3),
    generateConfig('LikeCriminal', '8.5K', small_n8_d3_m8, 8, 3, 8)
];
fs.writeFileSync(resolve(__dirname, 'config_2.json'), JSON.stringify(config, null, 2));

config.push(generateConfig('Big', '60K', small_n8_d5_m5, 8, 5, 5));
fs.writeFileSync(resolve(__dirname, 'config_3.json'), JSON.stringify(config, null, 2));

config.push(generateConfig('Biggest', '1.2M', small_n8_d10_m3, 8, 10, 3));
fs.writeFileSync(resolve(__dirname, 'config_4.json'), JSON.stringify(config, null, 2));

config.push(generateConfig('Medium', '24K', small_n8_d4_m6, 8, 4, 6));
fs.writeFileSync(resolve(__dirname, 'config_5.json'), JSON.stringify(config, null, 2));