/** 
* @description case factory used to build cases 
* @Owner: Grumpycats
*/
public with sharing class CaseFactoryCustomerOnboarding extends CaseFactory{

    private static final String FIELD_NAME_ACCOUNT_ID = 'AccountId';
    private static final String FIELD_NAME_PERSON_CONTACT_ID = 'PersonContactId';
    private static final String FIELD_NAME_ACCOUNT_NAME = 'Name';
    private static final String FIELD_NAME_OPPORTUNITY_ID = 'OpportunityId';
    private static final String FIELD_NAME_ID = 'Id';
    /**
     * @description buildCase
     * @param sobjectRecod 
     * @param ownerId 
     * @return  `Case`
     */
    public Case buildCase(SObject sobjectRecod, Id ownerId){
        Map<String, String> fieldNameToValueMap = setupFields(sobjectRecod);
        Case newCustomerOnboardingCase = new Case();
            newCustomerOnboardingCase.Subject = ('New Customer Onboarding - ' + fieldNameToValueMap.get(FIELD_NAME_ACCOUNT_NAME));
            newCustomerOnboardingCase.Description = 'A prospect has just become a new customer.';
            newCustomerOnboardingCase.ContactId = fieldNameToValueMap.get(FIELD_NAME_PERSON_CONTACT_ID);
            newCustomerOnboardingCase.AccountId = fieldNameToValueMap.get(FIELD_NAME_ACCOUNT_ID);
            newCustomerOnboardingCase.OwnerId = ownerId;
            newCustomerOnboardingCase.RecordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_ONBOARDING;
            if(String.isNotBlank(assignedTo)){
                newCustomerOnboardingCase.Assigned_To__c = assignedTo;
            }else{
                newCustomerOnboardingCase.Assigned_To__c = UserInfo.getUserId();
            }
            if(String.isNotBlank(fieldNameToValueMap.get(FIELD_NAME_OPPORTUNITY_ID))){
                newCustomerOnboardingCase.Opportunity_Related_To__c = fieldNameToValueMap.get(FIELD_NAME_OPPORTUNITY_ID);
            }
        
        return newCustomerOnboardingCase;
    }
    
    
    private static Map<String, String> setupFields(SObject sobjectRecord){
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        SObjectType objType = sobjectRecord.getSObjectType();
        if(objType == Account.getSObjectType()){
            fieldNameToValueMap.put(FIELD_NAME_ACCOUNT_ID, String.valueOf(sobjectRecord.get(FIELD_NAME_ID)));
        	fieldNameToValueMap.put(FIELD_NAME_PERSON_CONTACT_ID, String.valueOf(sobjectRecord.get(FIELD_NAME_PERSON_CONTACT_ID)));
        	fieldNameToValueMap.put(FIELD_NAME_ACCOUNT_NAME, String.valueOf(sobjectRecord.get(FIELD_NAME_ACCOUNT_NAME)));
        }else if(objType == Opportunity.getSObjectType()){
            fieldNameToValueMap.put(FIELD_NAME_ACCOUNT_ID, String.valueOf(sobjectRecord.get(FIELD_NAME_ACCOUNT_ID)));
        	fieldNameToValueMap.put(FIELD_NAME_PERSON_CONTACT_ID, String.valueOf(sobjectRecord.getSobject('Account').get(FIELD_NAME_PERSON_CONTACT_ID)));
        	fieldNameToValueMap.put(FIELD_NAME_ACCOUNT_NAME, String.valueOf(sobjectRecord.getSobject('Account').get(FIELD_NAME_ACCOUNT_NAME)));
        	fieldNameToValueMap.put(FIELD_NAME_OPPORTUNITY_ID, String.valueOf(sobjectRecord.get(FIELD_NAME_ID)));
        }
        
        return fieldNameToValueMap;
    }
    
    
}