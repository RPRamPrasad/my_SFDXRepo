/** 
* @description case factory used to build customer service request cases 
* @Owner: Grumpycats
*/
public with sharing class CaseFactoryCustomerServiceRequest extends CaseFactory{
	/**
     * @description buildCase
     * @param accountObject 
     * @param caseOwnerId 
     * @return  `Case`
     */
     public Case buildCase(SObject accountObject, Id caseOwnerId){
        Case newCustomerServiceRequestCase = new Case();  
        	if(accountObject != null){
            	newCustomerServiceRequestCase.Subject = subject;
       			newCustomerServiceRequestCase.Description = description;
                newCustomerServiceRequestCase.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_SERVICE_REQUEST;
        		newCustomerServiceRequestCase.ContactId = String.valueOf(accountObject.get('PersonContactId'));
        		newCustomerServiceRequestCase.AccountId = String.valueOf(accountObject.get('Id'));
                if(String.isNotBlank(caseOwnerId)){
                    newCustomerServiceRequestCase.OwnerId = caseOwnerId;
                }else{
                    newCustomerServiceRequestCase.OwnerId = UserInfo.getUserId();
                }
                if(String.isNotEmpty(assignedTo)){
                    newCustomerServiceRequestCase.Assigned_To__c = assignedTo;
                }
                if(String.isNotBlank(appCode)){
                    newCustomerServiceRequestCase.App_Code__c = appCode;
                }
                if(String.isNotBlank(caseType)){
                    newCustomerServiceRequestCase.type = caseType;                
                }
                if(String.isNotBlank(reason)){
                    newCustomerServiceRequestCase.Reason = reason;
                }
        	}  
            return newCustomerServiceRequestCase;
    }
    
}