const ExcelJS = require('exceljs');

async function main() {
	const excelPath = process.argv[2];
	if (excelPath === undefined) {
		console.error("Input needs to be a path to excel file");
		process.exit(1);
	}

	const workbook = new ExcelJS.Workbook();
	await workbook.xlsx.readFile(excelPath);

	const indexOfDot = excelPath.lastIndexOf('.');
	const excelOutputPath = `${excelPath.substring(0, indexOfDot)}_cleaned${excelPath.substring(indexOfDot)}`;

	console.log("Starting to clean worksheets that start with 'Test '");
	const worksheetToRemove = [];
	workbook.eachSheet(worksheet => {
		const worksheetName = worksheet.name;
		if (worksheetName.startsWith("Test "))
			worksheetToRemove.push(worksheetName);
	});
	worksheetToRemove.forEach(worksheetName => workbook.removeWorksheet(worksheetName));

	console.log("Finished cleaning, saving the file...");
	await workbook.xlsx.writeFile(excelOutputPath);
}
main();
