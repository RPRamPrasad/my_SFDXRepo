/**
* Author : Task Force
* Date Created : 03/28/2019
* @description : This class is the handler class for Future Dated Follow-ups triggers.
* History:
*---------
* Task Force   03/28/2019:  Initial Development
* Task Force   03/28/2019:  Added Logic for lookup of Customer and Owner (User and Contact obejects) 
*/

public without sharing class AP_FutureDatedFollowUpTrigger {
	
    /**
    * @description  Update Future Dated Follow ups client Ids to a Customer in Salesforce
    * @param fdfList 
    * @param clientIdSet 
    */
	public static void updateFDFCustomerWithSalesforceId(List<Future_Dated_Follow_up__c> fdfList, Set<String> clientIdSet){
        List<Contact> contactList = [Select Id, ClientIdentifier__c from Contact where ClientIdentifier__c In :clientIdSet];
        Map<String, Contact> contactMap = new Map<String, Contact>();
        for(Contact contact: contactList)  {
            contactMap.put(contact.ClientIdentifier__c, contact);
        }

        for(Future_Dated_Follow_up__c fdf : fdfList){
            Contact contact = contactMap.get(fdf.ClientId__c);
            if(contact != null){
                fdf.Customer_Name__c = contact.Id;
            } else {
                fdf.adderror('No Client Record found for ' + fdf.ClientId__c + ' For the Owner: ' + fdf.OwnerId);
            }
        }

    }

	/**
    * @description Update Future Dated Follow ups Agent Associate Id to a Proxy Id in Salesforce
    * @param fdfList 
    * @param agentAssociateIdSet 
    */
    public static void updateFDFOwnerWithSalesforceId(List<Future_Dated_Follow_up__c> fdfList, Set<String> agentAssociateIdSet){
        List<User> userList = [Select Id, UserExternalID__c from User where UserExternalID__c In:agentAssociateIdSet];
        Map<String, User> userMap = new Map<String, User>();
        for(User user: userList){
            userMap.put(user.UserExternalID__c, user);
        }
        
        for(Future_Dated_Follow_up__c fdf : fdfList){
            String proxyUserKey = (fdf.Agent_Associate_Id__c + 'P');
            User user = userMap.get(proxyUserKey);
            if(user != null){
                fdf.OwnerId = user.Id;
            } else {
                fdf.adderror('No Owner Proxy found for ' + fdf.Agent_Associate_Id__c);
            }
        }
    }


    /**
    * @description Update Future Dated Follow ups Assigned To Associate Id to a User Id in Salesforce
    * @param fdfList 
    * @param assignedToAssociateIdSet 
    */
      public static void updateFDFAssignedToWithSalesforceId(List<Future_Dated_Follow_up__c> fdfList, Set<String> assignedToAssociateIdSet){
        List<User> userList = [Select Id, Associate_ID__c from User where Associate_ID__c In:assignedToAssociateIdSet];
        Map<String, User> userMap = new Map<String, User>();
        for(User user: userList){
            userMap.put(user.Associate_ID__c, user);
        }
        
        for(Future_Dated_Follow_up__c fdf : fdfList){
            User user = userMap.get(fdf.Assigned_To_Associate_Id__c);
            if(user != null){
                fdf.Assigned_To__c = user.Id;
            } else {
                fdf.Assigned_To_Associate_Id__c = null;
            }
        }
    }

}