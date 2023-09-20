let calculateIsConsentNotRunning = (swcRequestedDate, swcGrantedDate, TODAYS_DATE) => {
    return !(swcRequestedDate !== null && (swcGrantedDate === null || new Date(swcGrantedDate) > new Date(TODAYS_DATE)))
}

let calculateDateToCalculate = (swcGrantedDate, opportunityDate, TODAYS_DATE) => {
    return (swcGrantedDate !== null && new Date(swcGrantedDate) <= new Date(TODAYS_DATE)) ? swcGrantedDate : opportunityDate;
}

let calculateIsConsentNecessary = (isConsentNotRunning, relationshipToStateFarm, numberOfDaysToExpire) => {
    return isConsentNotRunning && (relationshipToStateFarm === 'Customer' || numberOfDaysToExpire >= 0); 
}

export {calculateDateToCalculate, calculateIsConsentNotRunning, calculateIsConsentNecessary};