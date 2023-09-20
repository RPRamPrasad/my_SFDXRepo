import { createRecord } from 'lightning/uiRecordApi';
import CAMPAIGN_FOLLOW_UP from '@salesforce/schema/CampaignFollowUp__c'
import CAMPAIGN from '@salesforce/schema/CampaignFollowUp__c.Campaign__c'
import DETAILS from '@salesforce/schema/CampaignFollowUp__c.Details__c'
import LANGUAGE from '@salesforce/schema/CampaignFollowUp__c.Language__c'
import NAME from '@salesforce/schema/CampaignFollowUp__c.Name'
import OWNER from '@salesforce/schema/CampaignFollowUp__c.OwnerId'
import PROGRAM from '@salesforce/schema/CampaignFollowUp__c.Program__c'
import PROVIDER from '@salesforce/schema/CampaignFollowUp__c.Provider__c'
import STATUS from '@salesforce/schema/CampaignFollowUp__c.Status__c'
import TYPE from '@salesforce/schema/CampaignFollowUp__c.Type__c'

const createRecordObject = (campaignFollowUp) => {
    const fields = {
        [CAMPAIGN.fieldApiName]: campaignFollowUp.campaign,
        [DETAILS.fieldApiName]: campaignFollowUp.details,
        [LANGUAGE.fieldApiName]: campaignFollowUp.language,
        [NAME.fieldApiName]: campaignFollowUp.name,
        [OWNER.fieldApiName]: campaignFollowUp.owner,
        [PROGRAM.fieldApiName]: campaignFollowUp.program,
        [PROVIDER.fieldApiName]: campaignFollowUp.provider,
        [STATUS.fieldApiName]: campaignFollowUp.status,
        [TYPE.fieldApiName]: campaignFollowUp.type
    }

    return {
        apiName: CAMPAIGN_FOLLOW_UP.objectApiName,
        fields: fields
    }
}

const createCampaignFollowUp = (campaignFollowUp) => {
    const record = createRecordObject(campaignFollowUp)
    return createRecord(record)
}

export default createCampaignFollowUp