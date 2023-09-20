/**
* Author : Team ITIC
* Date Created :09/09/2019
* Description : Helper class to populate CampaignArchive record.
* @description AP_CampaignArchiveData 
* Used by AfterInsert and AfterDelete triggers.
*/
public with sharing class AP_CampaignArchiveData {
   /**
    * @description populateCampaignArchiveData
    * @param campaign 
    * @param recordTypeIdNameMap 
    * @return  `CampaignArchive__c`
    */ 
    public CampaignArchive__c populateCampaignArchiveData(Campaign campaign, Map<Id, String> recordTypeIdNameMap){
        CampaignArchive__c campaignArchive = new CampaignArchive__c();
        campaignArchive.ActualCost__c = campaign.ActualCost;
        campaignArchive.AmountAllOpportunities__c = campaign.AmountAllOpportunities;
        campaignArchive.AmountWonOpportunities__c = campaign.AmountWonOpportunities;
        campaignArchive.AssignedTo__c = campaign.Assigned_To__c;
        campaignArchive.BudgetedCost__c = campaign.BudgetedCost;
        campaignArchive.CampaignID__c = campaign.Campaign_Identifier__c;
        campaignArchive.Campaign_Member_Errors__c = campaign.Campaign_Member_Errors__c;
        campaignArchive.CampaignMemberRecordType__c = campaign.CampaignMemberRecordTypeId;
        campaignArchive.CurrentPathStep__c = campaign.CurrentPathStep__c;
        campaignArchive.OriginalCampaignCreatedById__c = campaign.CreatedById;
        campaignArchive.OriginalCampaignCreatedDate__c = campaign.CreatedDate;
        campaignArchive.Description__c = campaign.Description;
        campaignArchive.EndDate__c = campaign.EndDate;
        campaignArchive.ExpectedResponse__c = campaign.ExpectedResponse;
        campaignArchive.HardExpirationDate__c = campaign.HardExpirationDate__c;
        campaignArchive.HierarchyActualCost__c = campaign.HierarchyActualCost;
        campaignArchive.HierarchyAmountAllOpportunities__c = campaign.HierarchyAmountAllOpportunities;
        campaignArchive.HierarchyAmountWonOpportunities__c = campaign.HierarchyAmountWonOpportunities;        
        campaignArchive.HierarchyBudgetedCost__c = campaign.HierarchyBudgetedCost;
        campaignArchive.HierarchyExpectedRevenue__c = campaign.HierarchyExpectedRevenue;        
        campaignArchive.HierarchyNumberOfContacts__c = campaign.HierarchyNumberOfContacts;
        campaignArchive.HierarchyNumberOfConvertedLeads__c = campaign.HierarchyNumberOfConvertedLeads;
        campaignArchive.HierarchyNumberOfLeads__c = campaign.HierarchyNumberOfLeads;
        campaignArchive.HierarchyNumberOfOpportunities__c = campaign.HierarchyNumberOfOpportunities;
        campaignArchive.HierarchyNumberOfResponses__c = campaign.HierarchyNumberOfResponses;
        campaignArchive.HierarchyNumberOfWonOpportunities__c = campaign.HierarchyNumberOfWonOpportunities;
        campaignArchive.HierarchyNumberSet__c = campaign.HierarchyNumberSent;
        campaignArchive.Includes_Current_Resident__c = campaign.Includes_Current_Resident__c;
        campaignArchive.Initiated_By_Id__c = campaign.Initiated_By_Id__c;
        campaignArchive.Is_Custom_Demographics__c = campaign.Is_Custom_Demographics__c;
        campaignArchive.Is_Expired__c = campaign.Is_Expired__c;
        campaignArchive.IsActive__c = campaign.IsActive;
        campaignArchive.Journey_Description__c = campaign.Journey_Description__c;
        campaignArchive.Journey_Funding_Identifier__c = campaign.Journey_Funding_Identifier__c;
        campaignArchive.Journey_ID__c = campaign.Journey_ID__c;
        campaignArchive.Journey_Name__c = campaign.Journey_Name__c;
        campaignArchive.Journey_Start_Date__c = campaign.Journey_Start_Date__c;
        campaignArchive.Last_Worked__c = campaign.Last_Worked__c;
        campaignArchive.LastMessageSentDate__c = campaign.LastMessageSentDate__c;
        campaignArchive.OriginalCampaignLastModifiedById__c = campaign.LastModifiedById;
        campaignArchive.OriginalCampaignLastModifiedDate__c = campaign.LastModifiedDate;
        campaignArchive.OriginalExpirationDate__c = campaign.OriginalExpirationDate__c;
        campaignArchive.LockedCmp__c = campaign.LockedCmp__c;
        campaignArchive.Name = campaign.Name;
        campaignArchive.Number_of_Cases_Generated__c = campaign.Number_of_Cases_Generated__c;
        campaignArchive.Number_of_Simple_Conversations_Generated__c = campaign.Number_of_Simple_Conversations_Generated__c;
        campaignArchive.NumberOfCampaignMemberRemoved__c = campaign.NumberOfCampaignMemberRemoved__c;
        campaignArchive.NumberOfContacts__c = campaign.NumberOfContacts;
        campaignArchive.NumberOfConvertedLeads__c = campaign.NumberOfConvertedLeads;
        campaignArchive.NumberOfConvertedLeadsCustom__c = campaign.NumberOfConvertedLeads__c;
        campaignArchive.NumberOfLeads__c = campaign.NumberOfLeads;
        campaignArchive.NumberOfOpportunities__c = campaign.NumberOfOpportunities;
        campaignArchive.NumberOfResponses__c = campaign.NumberOfResponses;
        campaignArchive.NumberOfWonOpportunities__c = campaign.NumberOfWonOpportunities;
        campaignArchive.NumberSent__c = campaign.NumberSent;
        campaignArchive.OfficeAssigned__c = campaign.Office_Assigned__c;
        campaignArchive.OfficeLocation__c = campaign.Office_Location__c;
        campaignArchive.OriginalCampaignCount__c = campaign.Original_Campaign_Count__c;
        campaignArchive.Owner__c = campaign.OwnerId;
        campaignArchive.ParentCampaignId__c = campaign.ParentId;
        campaignArchive.CampaignRecordType__c = recordTypeIdNameMap.get(campaign.RecordTypeId);  
        campaignArchive.Selected_Journey_Start_Date__c = campaign.Selected_Journey_Start_Date__c;
        campaignArchive.Source__c = campaign.Source__c;
        campaignArchive.StartDate__c = campaign.StartDate;
        campaignArchive.Status__c = campaign.Status;
        campaignArchive.SubmittedCampaignCount__c = campaign.Submitted_Campaign_Count__c;
        campaignArchive.SubType__c = campaign.SubType__c;
        campaignArchive.TaskProgress__c = campaign.TaskProgress__c;
        campaignArchive.Total_Number_Members__c = campaign.Total_Number_Members__c;
        campaignArchive.TotalCalls__c = campaign.TotalCalls__c;
        campaignArchive.TotalEmailsSent__c = campaign.TotalEmailsSent__c;
        campaignArchive.TotalTextsSent__c = campaign.TotalTextsSent__c;
        campaignArchive.Type__c = campaign.Type;
		campaignArchive.OriginalCampaignSfdcID__c = campaign.Id;
        campaignArchive.NewOpportunityCreatedCount__c = campaign.NewOpportunityCreatedCount__c;
        campaignArchive.Assigned_to_Campaign__c = campaign.Assigned_to_Campaign__c;
        return campaignArchive;
    }

}