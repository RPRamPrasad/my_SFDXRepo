import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';
import retrieveSObjectsNotCacheable from '@salesforce/apex/SObjectRetrieveController.retrieveSObjectsNotCacheable';

const sObjectRetrieveRequest = {
    sobjectName: 'Campaign',
    fieldNames: ['Id', 'CampaignMembersAssignedToList__c', 'Total_Number_Members__c', 
                 'RecordType.DeveloperName', 'Source__c', 'Original_Campaign_Count__c',
                 'TotalEmailsSent__c', 'isCampaignMemberAssigned__c', 'Owner.Servicing_Agent_Associate_ID__c', 
                 'Status', 'SubType__c', 'PhoneFollowUpStatus__c', 'Name'],
    filterCriteriaIn: [{
        enable: true,
        filterFieldName: 'Id',
        queryNullValues: false,
        filterValues: undefined,
        filterType: 'LIST_OF_STRING'
    }],
    queryLimit: 1
}


export default async function retrieveCampaignDetails(recordId, useCache) {
    const retrieveRequest = await copyRetrieveRequest(recordId);
    return { 
        recordId: recordId,
        request: retrieveRequest,
        result: await executeQuery(retrieveRequest, useCache),
        refresh: async function() { this.result = await executeQuery(this.request, useCache); }
    }
}

async function copyRetrieveRequest(recordId) {
    const retrieveRequest = JSON.parse(JSON.stringify(sObjectRetrieveRequest));
    retrieveRequest.filterCriteriaIn[0].filterValues = [recordId];

    return retrieveRequest;
}

async function executeQuery(request, useCache) {
    if (useCache) { 
        return retrieveSObjects({ request: request })
    }
    return retrieveSObjectsNotCacheable({ request: request })
}