import { createRecord } from 'lightning/uiRecordApi';
import CAMPAIGN_ACTION_OBJECT from '@salesforce/schema/CampaignAction__c';
import ACTION_FIELD from '@salesforce/schema/CampaignAction__c.Action__c';
import CAMPAIGN_FIELD from '@salesforce/schema/CampaignAction__c.Campaign__c';
import CAMPAIGN_ID_FIELD from '@salesforce/schema/CampaignAction__c.CampaignId__c';
import CLIENT_FIELD from '@salesforce/schema/CampaignAction__c.ClientIdentifier__c';
import DESCRIPTION_FIELD from '@salesforce/schema/CampaignAction__c.Description__c';
import LEAD_FIELD from '@salesforce/schema/CampaignAction__c.LeadIdentifier__c';
import OWNER_FIELD from '@salesforce/schema/CampaignAction__c.OwnerId';
import REFERENCE_SOBJECT_FIELD from '@salesforce/schema/CampaignAction__c.ReferenceSObject__c';
import REFERENCE_ID_FIELD from '@salesforce/schema/CampaignAction__c.ReferenceId__c';

const actions = {
    sentEmail: 'Sent Email',
    sentText: 'Sent Text',
    phoneCall: 'Phone Call',
    opportunityCreated: 'Opportunity Created',
    leadConverted: 'Lead Converted',
    peopleRemoved: 'People Removed',
    newLog: 'New Log',
    newCase: 'New Case',
    simpleConversation: 'Simple Conversation',
    phoneFollowUpSubmitted: 'Phone Follow Up Submitted',
    goodNeighborConnect: 'Good Neighbor Connect'
}


const createRecordObject = (campaignAction) => {

    const fields = {
        [ACTION_FIELD.fieldApiName]: campaignAction.action,
        [CAMPAIGN_FIELD.fieldApiName]: campaignAction.campaignId,
        [CAMPAIGN_ID_FIELD.fieldApiName]: campaignAction.campaignId,
        [CLIENT_FIELD.fieldApiName]: campaignAction.clientId,
        [DESCRIPTION_FIELD.fieldApiName]: campaignAction.description,
        [LEAD_FIELD.fieldApiName]: campaignAction.leadId,
        [OWNER_FIELD.fieldApiName]: campaignAction.owner,
        [REFERENCE_SOBJECT_FIELD.fieldApiName]: campaignAction.sObjectName,
        [REFERENCE_ID_FIELD.fieldApiName]: campaignAction.sObjectId
    };

    return {
        apiName: CAMPAIGN_ACTION_OBJECT.objectApiName,
        fields: fields
    };
};

const createCampaignAction = (campaignAction) => {

    const record = createRecordObject(campaignAction)
    return createRecord(record);
}

export {
    createCampaignAction,
    actions
}