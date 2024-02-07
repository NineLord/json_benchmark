const ExcelJS = require('exceljs');

/**
 * @param {Row} row 
 * @param {number} index 
 * @returns {null|number}
 */
function getPercentage(row, index) {
	const percentageString = row.getCell(index).value;
	if (percentageString === null)
		return null; // Invalid row / last row
	const percentage = parseFloat(percentageString.replace('%', ''));
	if (isNaN(percentage)) {
		console.log(`Got in row ${row.number} column ${index} an invalid percentage: ${percentageString}`);
		return null;
	}

	return percentage;
}

/**
 * @param {Row} row 
 * @param {number} index 
 * @returns {null|number}
 */
function getNumber(row, index) {
	const numberString = row.getCell(index).value;
	if (numberString === null)
		return null; // Invalid row / last row
	const number = parseFloat(numberString);
	if (isNaN(number)) {
		console.log(`Got in row ${row.number} column ${index} an invalid number: ${numberString}`);
		return null;
	}

	return number;
}

/**
 * @param {Worksheet} worksheet 
 */
function sumUp(worksheet, numberOfCores) {
	let cpuSum = 0;
	let cpuSumOutOfAll = 0;
	let ramSum = 0;
	let swpSum = 0;
	

	let numberOfRows = 0;
	const dataRows = worksheet.getRows(7, worksheet.lastRow.number);
	dataRows.forEach(row => {
		let sumAverageCores = 0;
		for (let index = 1; index <= numberOfCores; ++index) {
			const percentage = getPercentage(row, index);
			if (percentage === null)
				return;

			sumAverageCores += percentage;
		}

		const average = getPercentage(row, numberOfCores + 2);
		if (average === null)
			return;

		const ram = getNumber(row, numberOfCores + 3);
		if (ram === null)
			return;

		const swp = getNumber(row, numberOfCores + 5);
		if (swp === null)
			return;

		++numberOfRows;
		cpuSum += average;
		ramSum += ram;
		swpSum += swp;
		row.getCell(numberOfCores + 1).value = `${sumAverageCores}%`;
		cpuSumOutOfAll += sumAverageCores;
	});


	const cpuAverageCell = worksheet.getRow(1).getCell(2);
	cpuAverageCell.value = cpuSum / numberOfRows;

	const cpuAverageOutOfAllCell = worksheet.getRow(2).getCell(2);
	cpuAverageOutOfAllCell.value = cpuSumOutOfAll / numberOfRows;

	const ramAverageCell = worksheet.getRow(3).getCell(2);
	ramAverageCell.value = ramSum / numberOfRows;

	const swpAverageCell = worksheet.getRow(4).getCell(2);
	swpAverageCell.value = swpSum / numberOfRows;
}

/**
 * Parse from the input the number of cores.
 * @returns {number} the number of cores (or default value: 4).
 */
function getNumberOfCores() {
	const num = parseInt(process.argv[3]);
	if (isNaN(num)) {
		console.error("2nd Input needs to be the number of cores");
		process.exit(1);
	}

	return num;
}

/**
 * @returns {string}
 */
function getPathToCsv() {
	const result = process.argv[2];
	if (result === undefined) {
		console.error("Input needs to be a path to csv file");
		process.exit(1);
	}
	return result;
}

async function main() {
	const csvPath = getPathToCsv();
	const numberOfCores = getNumberOfCores();

	const workbook = new ExcelJS.Workbook();
	await workbook.csv.readFile(csvPath);

	console.log("Starting to sum up");
	sumUp(workbook.worksheets[0], numberOfCores);

	console.log("Finished cleaning, saving the file...");
	const indexOfDot = csvPath.lastIndexOf('.');
	const excelOutputPath = `${csvPath.substring(0, indexOfDot)}_summedUp.xlsx`;
	await workbook.xlsx.writeFile(excelOutputPath);
}
main();