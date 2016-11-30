// insert_columns.gs
//
// This code is a Google Apps Script that is attached to
//    "Management Report" google spreadsheet
//    https://docs.google.com/spreadsheets/d/1BY4Iqwp9pdtW3Q2702VsP8rLN0VXUntX0GJlJI0QANY
// It runs daily, weekly, monthly to insert new columns on the specified tabs.
//

// relevant spreadsheet columns
var NAME_COLUMN = 2,
    FORMULA_COLUMN = 6,
    FIRST_DATA_COLUMN = 8;

/**
 * Triggered at midnight UTC daily
 */
function insertDayColumns() {
    insertColumns('Daily', oneDayLater);
    insertColumns('WIP - Growth Daily', oneDayLater);
}

/**
 * Triggered at midnight UTC every Monday
 */
function insertWeekColumns() {
    insertColumns('Weekly', oneWeekLater);
}

/**
 * Triggered at midnight UTC every 1st of the month
 */
function insertMonthColumns() {
    insertColumns('Monthly', oneMonthLater);
    insertColumns('WIP - Growth Monthly', oneMonthLater);
}

/**
 * Insert date columns where date represents period that has passed
 * (day or week or month)
 *
 * @param {String} worksheet name
 * @param {Function} laterDate function takes a Date and returns a later Date
 *
 */
function insertColumns(worksheet, laterDate) {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(worksheet);
    //var col = getLastDateColumn(sheet);
    var col = FIRST_DATA_COLUMN;
    var today = new Date();

    Logger.log('running insertColumns() on  ""'+ worksheet +'" at "'+ today);

    if (col !== null) {

        var current,            // date represented by current column header
            next,               // one period from current
            following;          // two periods from current

        // First column is fixed. Insert column before FIRST_DATA_COLUMN.

        do {
            current = sheet.getRange(1, col).getValue();
            next = laterDate(current);
            following = laterDate(next);

            if (today > following) {
                Logger.log('inserting: '+ col +' '+ next);
                sheet.insertColumnBefore(col);
                //col -= 1;
                sheet.getRange(1, col).setValue(next);
                propagateFormulas(sheet, col);
            }
        } while (today > following)
    }
}

function oneDayLater(originalDate) {
    var laterDate = new Date(originalDate);
    laterDate.setDate(laterDate.getDate() + 1);
    return laterDate;
}

function oneWeekLater(originalDate) {
    var laterDate = new Date(originalDate);
    laterDate.setDate(laterDate.getDate() + 7);
    return laterDate;
}

function oneMonthLater(originalDate) {
    var laterDate = new Date(originalDate);
    laterDate.setMonth(laterDate.getMonth() + 1);
    return laterDate;
}

/**
 * find the column number of the last date containing column.
 * walk the column headings to find the not-a-date column.
 *
 * @param {Sheet} sheet worksheet in question
 * @returns {Number} column number last date column, null if not found
 */
function getLastDateColumn(sheet) {
    var lastDateColumn = null;

    for (var col = FIRST_DATA_COLUMN; col <= sheet.getLastColumn(); col++) {
        if (typeof(sheet.getRange(1, col).getValue()) == "string") {
            lastDateColumn = col - 1
            break;
        }
    }

    if (lastDateColumn === null) {
        Logger.log('ERROR: last date column not found.' );
    }

    return lastDateColumn;
}

/**
 * deal with previous column's formulas
 *
 * @param {Sheet} sheet worksheet in question
 * @param {Number} column
 */
function propagateFormulas(sheet, column) {

    // Walk the rows, for each row that represents a formula,
    // copy the formula from the previous cell to the new column for that row
    // and paste it in the new column
    for (var row = 2; row <= sheet.getLastRow(); row++) {
        if (sheet.getRange(row, FORMULA_COLUMN).getValue().toLowerCase() == 'x') {
            sheet.getRange(row, column + 1).copyTo(sheet.getRange(row, column));
        }
    }
}
