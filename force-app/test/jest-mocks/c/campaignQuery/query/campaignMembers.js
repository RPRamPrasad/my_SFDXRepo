import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';
import retrieveSObjectsNotCacheable from '@salesforce/apex/SObjectRetrieveController.retrieveSObjectsNotCacheable';

const sObjectRetrieveRequest = {
    sobjectName: 'CampaignMember',
    fieldNames: ['id','SendText__c','CampaignName__c', 'LeadId', 'AccountId__c','ContactId','Email', 'Email__c','CampaignId','Contact.AccountId', 'Name', 'Removed__c', 'LeadUploadSortingOrder__c'
    ,'CustProspectSortingOrder__c', 'IsPhoneDoNotMarket__c','Phone', 'MobilePhone', 'TotalCalls__c', 'SubmittedPhone__c', 'IsMobilePhoneDoNotMarket__c'
    ,'DisplayCampMembStatus__c', 'HomePhone__c', 'TotalEmailsSent__c', 'AssignedTo__c', 'Do_Not_Call__c', 'SubmittedDoNotCall__c', 'Status__c','DisplayName__c','Type','Campaign.Type','PhoneDoNotCall__c, HasPhoneNumber__c', 'ExternalData__c','LastName', 'PreferredSpokenLanguage__c','AdditionalInfo__c'],
    filterCriteriaIn: [{
        enable: true,
        filterFieldName: 'CampaignId',
        queryNullValues: false,
        filterValues: undefined,
        filterType: 'LIST_OF_STRING'
    }],
    queryLimit: 4000
}

export default async function retrieveCampaignMembers(campaignId, filterBy, sortedBy, campaignMemberCount, useCache) {
    return { 
        campaignId: campaignId,
        filterBy: filterBy,
        sortedBy: sortedBy,
        result: await executeQuery(campaignId, filterBy, sortedBy, campaignMemberCount, useCache),
        refresh: async function() { this.result = await executeQuery(this.campaignId, this.filterBy, this.sortedBy, campaignMemberCount, useCache); },
    }
}

async function executeQuery(campaignId, filterBy, sortedBy, campaignMemberCount, useCache) {
    const request = copyRetrieveRequest(campaignId, filterBy, sortedBy, campaignMemberCount);
    if (useCache) { 
        return retrieveSObjects({ request: request })
    }
    return retrieveSObjectsNotCacheable({ request: request })
}

function copyRetrieveRequest(campaignId, filterBy, sortedBy, campaignMemberCount) {
    const retrieveRequest = JSON.parse(JSON.stringify(sObjectRetrieveRequest));
    retrieveRequest.filterCriteriaIn[0].filterValues = [campaignId];
    if(campaignMemberCount) {
        retrieveRequest.queryLimit = campaignMemberCount
    }
    if (filterBy) {
        if (Array.isArray(filterBy)) {
            filterBy.forEach(item => {
                retrieveRequest.filterCriteriaIn.push(item);
            })
        } else {
            retrieveRequest.filterCriteriaIn.push(filterBy);
        }
    }

    if (sortedBy) {
        if (Array.isArray(sortedBy)) {
            retrieveRequest.orderByCriteriaIn = sortedBy;
        } else {
            retrieveRequest.orderByCriteriaIn = [sortedBy];
        }
    }

    return retrieveRequest;
}