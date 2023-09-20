/**
* @author Team Loco Motivated
* @name HLPR_CustomerGroupMemberResponse 
* This is JSON object for household management response 
* @description HLPR Customer GroupMember Response
* @Date : 03/05/2018
**/

public with sharing class HLPR_CustomerGroupMemberResponse {
    
    //Populate Customer Group Member values received from Household management response
    /**
     * @description Get Customer Group Member From HHMgmt Response
     * @param dataListValues
     * @return List<CustomerGroupMember__c>
     */
    public static List<CustomerGroupMember__c> getCustomerGroupMemberFromHHMgmtResponse(List<AP_CustomerGroupMemberResponse.CustomerGroupData> dataListValues) {
        List<CustomerGroupMember__c> custGroupMemList=new List<CustomerGroupMember__c>();
        if(dataListValues.isEmpty()){
            throw new CustomerAggregatorException('Household Management Response empty');
        }
        for(AP_CustomerGroupMemberResponse.CustomerGroupData jsonGroupMemberValue : dataListValues){
            CustomerGroupMember__c custGroupMem = new CustomerGroupMember__c();
            custGroupMem.Group__r = new CustomerGroup__c(SFGroupIdentifier__c =jsonGroupMemberValue.groupId);
            custGroupMem.Customer__r = new account(clientIdentifier__c=jsonGroupMemberValue.customer);
            custGroupMem.GroupMemberId__c = jsonGroupMemberValue.groupId+'~'+jsonGroupMemberValue.customer;
            custGroupMemList.add(custGroupMem);
        }
        return custGroupMemList; 
    }    
}