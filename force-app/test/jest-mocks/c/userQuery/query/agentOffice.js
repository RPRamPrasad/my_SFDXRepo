import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';

const REQUEST_TEMPLATE = {
    sobjectName: 'User',
    fieldNames: ['Id', 'Name', 'Profile.Name'],
    filterCriteriaIn: [
        {
            enable: true,
            filterFieldName: 'Servicing_Agent_Associate_ID__c',
            queryNullValues: false,
            filterValues: [],
            filterType: 'LIST_OF_STRING'
        },
        {
            enable: true,
            filterFieldName: 'IsActive',
            queryNullValues: false,
            filterValue: true,
            filterType: 'BOOLEAN'
        },
        {
            enable: true,
            filterFieldName: 'Profile.Name',
            queryNullValues: false,
            filterValues: ['2.00 Agent', '2.01 Agent Team Member'],
            filterType: 'LIST_OF_STRING'
        },
        {
            enable: true,
            filterFieldName: 'FederationIdentifier',
            queryNullValues: false,
            filterValue: '',
            filterType: 'NOT_BLANK'
        }
    ],
    queryLimit: 500
}

export default async function retrieveAgentOffice(servicingAgentExternalId) {
    const request = createRequest(servicingAgentExternalId);
    const result = await executeQuery(request);
    return {
        servicingAgentExternalId: servicingAgentExternalId,
        request: request,
        result: result,
        agentOffice: parseAgentOffice(result),
        refresh: async function() { 
            this.result = await executeQuery(this.request);
            this.agentOffice = parseAgentOffice(this.result);
        }
    };
}

function createRequest(servicingAgentExternalId) {
    const request = JSON.parse(JSON.stringify(REQUEST_TEMPLATE));
    request.filterCriteriaIn[0].filterValues = [servicingAgentExternalId];

    return request;
}

async function executeQuery(request) {
    return retrieveSObjects({ request: request});
}

function parseAgentOffice(result) {
    return result.sobjects;
}