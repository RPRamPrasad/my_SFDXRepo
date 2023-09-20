import callout from '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation';

const formatDate = (date, delimiter = '-') => { 
    let dateObj = new Date(date); 
    
    const year = dateObj.getUTCFullYear(); 
    const month = dateObj.getUTCMonth() + 1; // Month starts at 0 
    const day = dateObj.getUTCDate(); 
    return [year, month < 10 ? '0' + month : month, day < 10 ? '0' + day : day].join(delimiter); 
}

export const buildDVLInput = (lob, agreementAccessKey, asOfDate, sourceSystemCode) => {
    return {
        calloutName: 'PolicyDetailsDVLByDate_TP2',
        calloutParams: [
            lob, 
            agreementAccessKey, 
            asOfDate,
            sourceSystemCode 
        ]
    }
}

const handleDVLResponse = (response, lob, agreementAccessKey, sourceSystemCode) => {
    if (response.statusCode === 200) {
        // if 200, call success, extract and return details
        return JSON.parse(response.body).policy;
    } 

    let responseBody = JSON.parse(response.body).errorMsg
    if (response.statusCode === 400) {
        // if 400, call failed for date input, extract date from error, format and recall
        let date;
        if (response.body.includes('AsofDate is Later than Policy Term End Date')) {
            date = new Date(responseBody.substring(responseBody.length - 10, responseBody.length));
            
            date = formatDate(date.setDate(date.getDate() - 1));
        } else if (response.body.includes('AsofDate is Prior to Policy Term Start Date')) {
            date = responseBody.substring(responseBody.length - 10, responseBody.length);
        } else throw new Error(responseBody);

        // eslint-disable-next-line no-use-before-define
        return retrieveDetails(lob, agreementAccessKey, sourceSystemCode, date);
    }

    // if status is 404, 500, or other, throw error to source component
    throw new Error(response.statusCode + ': ' + responseBody)
}

export const retrieveDetails = async (lob, agreementAccessKey, sourceSystemCode, date = new Date()) => {
    
    let dateParam = formatDate(date)
    let input = buildDVLInput(lob, agreementAccessKey, dateParam, sourceSystemCode)
    let response;

    response = await callout({ input });
    return handleDVLResponse(response, lob, agreementAccessKey, sourceSystemCode);
}
