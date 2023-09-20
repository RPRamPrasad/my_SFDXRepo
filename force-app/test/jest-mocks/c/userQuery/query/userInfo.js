import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';

const REQUEST_TEMPLATE = {
    sobjectName: 'User',
    fieldNames: ['Id', 'Name', 'Profile.Name', 'ClickToDialEnabled__c', 'ClickToDialPreference__c', 'IsActive', 'Servicing_Agent_Associate_ID__c','UserType__c'],
    filterCriteriaIn: [
        {
            enable: true,
            filterFieldName: 'Id',
            queryNullValues: false,
            filterValues: undefined,
            filterType: 'LIST_OF_STRING'
        }
    ],
    queryLimit: 500
}

export default async function retrieveUser(userId) {
    const request = createRequest(userId);
    const result = await executeQuery(request);
    return {
        userId: userId,
        request: request,
        result: result,
        user: parseUser(result, Array.isArray(userId)),
        refresh: async function() { 
            this.result = await executeQuery(this.request);
            this.user = parseUser(this.result, Array.isArray(this.userId));
        }
    };
}

function createRequest(userId) {
    const request = JSON.parse(JSON.stringify(REQUEST_TEMPLATE));

    if(Array.isArray(userId)) {
        request.filterCriteriaIn[0].filterValues = userId;
    } else {
        request.filterCriteriaIn[0].filterValues = [userId];
    }

    return request;
}

async function executeQuery(request) {
    return retrieveSObjects({ request: request});
}

function parseUser(result, isArray) {
    if (result.sobjects && !isArray) {
        return result.sobjects[0];
    }

    return result.sobjects;
}