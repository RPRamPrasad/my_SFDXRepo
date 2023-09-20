/**
 * @Author: Targaryen
 * @description : Account Trigger helper class for updating Org Account Leads 
 * Update : On part of marking smaller class this class is created for leads and campaign members.
 */
public with sharing class AP_AccountTriggerHelper {
    /** 
      * @description Method to update organization account records sourced from LeadConversion.
      * @param  accountList
      */
    public static void updateOrgAccountForLead(List<Account> accountList) {
        String orgActRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME).getRecordTypeId();
        for(Account act: accountList) {
            if(act.IsSourcedFromLead__c && orgActRecordTypeId.equals(act.RecordTypeId)) {
                if(String.isNotBlank(act.FirstName)) {
                    act.FirstName = '';
                }
            }
        }
    }

    /**
      *  @description method to handle accounts updates for compaign members
      *  @param  newStateOfAccounts 
      *  @param  priorStateOfAccounts  
      */
    public void handleAccountsAfterUpdate(List<Account> newStateOfAccounts, Map<Id,Account>  priorStateOfAccounts){
        triggerUpdateOnAssociatedCampaignMembers(getContactIdsFromAccounts(
            filterAccountsThatWereNoPhoneNumber(newStateOfAccounts, priorStateOfAccounts)));
    }
    private void triggerUpdateOnAssociatedCampaignMembers(List<ID> contactIds) {
        List<CampaignMember> campaignMembers = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT ID from CampaignMember where ContactId in :contactIds])
                                                  .getRecords();

        if(!campaignMembers.isEmpty()){
            update CampaignMembers =Security.stripInaccessible(AccessType.UPDATABLE, CampaignMembers).getRecords();
        }
    }
    private List<Account> filterAccountsThatWereNoPhoneNumber(List<Account> newStateOfAccounts, Map<Id,Account>  priorStateOfAccounts){
        List<Account> filteredAccounts = new List<Account>();
    
        for(Account newStateOfAccount: newStateOfAccounts){
            if(wasAccountNoPhoneNumber(newStateOfAccount, priorStateOfAccounts.get(newStateOfAccount.Id))){
                filteredAccounts.add(newStateOfAccount);
            }
        }
        return filteredAccounts;
    }

    private Boolean wasAccountNoPhoneNumber(Account newStateOfAccount, Account priorStateOfAccount){
        if(String.isBlank(priorStateOfAccount.PersonHomePhone) && String.isBlank(priorStateOfAccount.PersonMobilePhone)){
            return (String.isNotBlank(newStateOfAccount.PersonHomePhone) || String.isNotBlank(newStateOfAccount.PersonMobilePhone));
        }else{
            return false;
        }
    }
    private List<ID> getContactIdsFromAccounts(List<Account> accounts){
        List<Id> ids = new List<ID>();
        for(Account account: accounts){
            if(account.PersonContactId != null){
                ids.add(account.PersonContactId);
            }
        }
        return ids;
    }
}
