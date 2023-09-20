export const extractDateString = inputDate => {
    let date;
    
    // Regex: year, month, day
    // ####-##-##
    const dateRegex = /\d{4}-\d{2}-\d{2}/g;

    const dateArray = inputDate.match(dateRegex);

    if (dateArray && dateArray.length) {
        // Replace hyphens with slash in order to change the date parser to not be
        // timezone dependent. This will give the actual day provided by DVL.
        // https://stackoverflow.com/questions/7556591/is-the-javascript-date-object-always-one-day-off
        date = dateArray[0].replace(/-/g, "/");
    }

    return date;
}

// This will convert data from YYYY-MM-DD to MM-DD-YYYY. Consistent display of dates on Policy Details. 
export const formatDate = inputDate => {
    let outputDate;

    const inputYear = inputDate.substring(0, 4);
    const inputMonth = inputDate.substring(5, 7);
    const inputDay = inputDate.substring(8, 10);
    outputDate = inputMonth + '-' + inputDay + '-' + inputYear;

    return outputDate;
}