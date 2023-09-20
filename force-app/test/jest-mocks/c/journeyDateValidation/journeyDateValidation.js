
export function calculateJourneyStartDate(dateToCalculate){
    var dayOfWeek = dateToCalculate.getDay();
    var dateOfMonth = dateToCalculate.getDate();
    var hour = dateToCalculate.getHours();
    var thisWeek = 7;
    var nextWeek = 14;
    var thisWeekend = 6;
    var dayNoon = 12;
    var returnValue;
    var addDays;
    if((dayOfWeek < thisWeekend) || (dayOfWeek === thisWeekend && hour <= dayNoon)){
        addDays = thisWeek - dayOfWeek;
        returnValue = new Date(dateToCalculate.setDate(dateOfMonth + addDays));
    }else{
        addDays = nextWeek - dayOfWeek;
        returnValue = new Date(dateToCalculate.setDate(dateOfMonth + addDays));    
    }
    return new Date(returnValue.toDateString());
}

export function formatDate(dateToFormat){
    let dd = dateToFormat.getDate();
    dateToFormat.setHours(20);
    let mm = dateToFormat.getMonth() + 1; 
    const yyyy = dateToFormat.getFullYear();
    if(dd<10){
        dd=`0${dd}`;
    } 
    if(mm<10){
        mm=`0${mm}`;
    }
    return `${yyyy}-${mm}-${dd}`;
}

export function addYears(currentDate, nYear){
    var dateObject = new Date(currentDate);
    var day = dateObject.getDate();
    dateObject.setHours(20); // avoid date calculation errors
    dateObject.setMonth(dateObject.getMonth() + 1, 0);
    // set day number to min of either the original one or last day of month
    dateObject.setDate(Math.min(day, dateObject.getDate())); 
    dateObject.setFullYear(dateObject.getFullYear() + nYear);
    return dateObject.toISOString().split('T')[0];
}

// function to format date in MM/DD/YYYY
export function formattedDateMMDDYYYY(dateToFormat){
    let dd = dateToFormat.getDate() + 1;
    let mm = dateToFormat.getMonth() + 1; 
    const yyyy = dateToFormat.getFullYear();
    if(dd<10){
        dd=`0${dd}`;
    } 
    if(mm<10){
        mm=`0${mm}`;
    }
    return `${mm}/${dd}/${yyyy}`;
}