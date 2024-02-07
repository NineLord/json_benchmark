#!/usr/local/bin/node

const bashColorsRegex = /[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g;

const numbersRegex = "(\\d)+";
const percentageRegex = new RegExp(`${numbersRegex}\\.${numbersRegex}%`);

const numberWithMaybeFractionRegex = `${numbersRegex}(\\.${numbersRegex})?`;
const kiloMegaGigaSymbolsRegex = "(K|M|G)";
const memoryRegex = `${numberWithMaybeFractionRegex}${kiloMegaGigaSymbolsRegex}`;
const totalMemoryRegex = new RegExp(`${memoryRegex}\/${memoryRegex}`);

/**
 * Appends the found regex in data to the final result.
 * @param {string} data The data to be parsed.
 * @param {string} finalResult The result that the found data will be appended to it.
 * @returns {string} the data without the found result and anything that came before it.
 */
function appendCpu(data, finalResult) {
	const match = data.match(percentageRegex);
	if (match === null) {
		finalResult.push(',');
		return data;
	} else {
		const matchResult = match[0];
		finalResult.push(`${matchResult},`);

		// Removing result and anything that came before that for the next iteration
		return data.substring(match.index + matchResult.length);
	}
}

/**
 * 
 * @param {string} memory 
 * @return {number}
 */
function convertMemoryTextToMb(memory) {
	const splitIndex = memory.length - 1;
	let number = parseFloat(memory.slice(0, splitIndex));
	if (isNaN(number))
		return undefined;
	const unit = memory.slice(splitIndex);
	switch (unit) {
		case 'K':
			return Math.round((number / 1024) * 100) / 100;
		case 'M':
			return number;
		case 'G':
			return number * 1024;
		default:
			return undefined;
	}
}

/**
 * Appends the found regex in data to the final result.
 * @param {string} data The data to be parsed.
 * @param {string} finalResult The result that the found data will be appended to it.
 * @returns {string} the data without the found result and anything that came before it.
 */
function appendRam(data, finalResult) {
	const match = data.match(totalMemoryRegex);
	if (match === null) {
		finalResult.push(',,');
		return data;
	}

	const matchResult = match[0];
	let [memoryUsed, totalMemory] = matchResult.split('/');
	memoryUsed = convertMemoryTextToMb(memoryUsed);
	if (memoryUsed === undefined) {
		finalResult.push(',,');
		return data;
	}
	finalResult.push(`${memoryUsed},${totalMemory},`);

	// Removing result and anything that came before that for the next iteration
	return data.substring(match.index + matchResult.length);
}

/**
 * Prints the CPU/RAM usage into csv format.
 * @param {string} data Data from pipe.
 * @param {number} numberOfCores The number of cores expected to have.
 */
function main(data, numberOfCores) {
	data = data.replace(bashColorsRegex, '');
	let result = [];

	//#region Get CPU Usage
	for (let coreNumber = 0; coreNumber < numberOfCores; ++coreNumber)
		data = appendCpu(data, result);
	result.push(',');
	data = appendCpu(data, result); // Appending the Average CPU Usage.
	//#endregion

	//#region Get RAM Usage
	for (let memoryInfoNumber = 0; memoryInfoNumber < 2; ++memoryInfoNumber)
		data = appendRam(data, result);
	//#endregion
	
	console.log(result.join(''));
}

/**
 * Parse from the input the number of cores.
 * @returns {number} the number of cores (or default value: 4).
 */
function numberOfCores() {
	const num = parseInt(process.argv[2]);
	if (isNaN(num))
		return 4;
	else
		return num;
}

//#region Get data from pipe
const stdin = process.openStdin();
let data = "";
stdin.on('data', chunk => data += chunk);
stdin.on('end', () => main(data, numberOfCores()));
//#endregion