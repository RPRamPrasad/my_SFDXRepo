import getCampaignMemberAssignedToCounts from '@salesforce/apex/CampaignAssignToController.retrieveCampaignMemberAssignedToCounts';

export default async function retrieveCapaignAssignToCounts(recordId) {
    return { 
        recordId: recordId,
        result: await executeQuery(recordId),
        refresh: async function() { this.result = await executeQuery(this.recordId); }
    }
}

async function executeQuery(recordId) {
    return getCampaignMemberAssignedToCounts({ campaignId: recordId});
}