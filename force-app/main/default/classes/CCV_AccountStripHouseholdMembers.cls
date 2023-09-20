/**
@author CustomerView
@owner Team Atlas
@name CCV_AccountStripHouseholdMembers
@createDate 09/11/2022
@ModifiedDate 
@description This class is used by LWC accountHouseholdMembers to fetch Household Members data on load
@version 1.0
*/
public with sharing class CCV_AccountStripHouseholdMembers {
    /**
    * @description This method is used to members data in household
    * @name : fetchAccountDetails
    * @param hhRecordId : input record id
    * @param accRecordId : input object api name
    * @return HouseholdMembersWrapper : output Household members wrapper
    */
    @AuraEnabled(cacheable = true)
    public static HouseholdMembersWrapper fetchHouseholdMembersDetails(String hhRecordId, String accRecordId) {
        try {
        List<Relationship__c> relationships = getRelationshipDetails(hhRecordId,accRecordId);
        Integer counter = 0;
        Map<Id, Relationship__c> relationshipMap = new Map<Id,Relationship__c>();
        for(Relationship__c rel:relationships) {
            relationshipMap.put(rel.AccountOne__c, rel);
        }
        SObjectAccessDecision memberSecurityDecision = getHouseholdMembersDetails(hhRecordId);
        List<AccountContactRelation> lstACR = memberSecurityDecision.getRecords();
            
        List<HouseholdMemberWrapper> groupMembers = new List<HouseholdMemberWrapper>();
        for(AccountContactRelation acr:lstACR){
            counter++;
            HouseholdMemberWrapper member = new HouseholdMemberWrapper();
            member.id = acr.Contact.AccountId;
            member.name = acr.Contact.Name;
            member.url = '/one/one.app#/sObject/'+acr.Contact.AccountId;
            member.recordTypeName = acr.Contact.Account.RecordType.Name;
            if(!isGenderAccessible(memberSecurityDecision, 'Gender__c')){
            	member.gender = acr.Contact.Gender__c;
            }
            member.birthDate = acr.Contact.Birthdate;
            member.age = String.valueOf(acr.Contact.Account.Age__c);
            member.deceased = acr.Contact.IsDeathNotificationReceived__c;
            member.deceasedDate = acr.Contact.DeathDate__c;
            member.preferredName = acr.Contact.Account.PreferredFirstName__c;
            member.relationshipNature = null;
            if(relationshipMap != null && relationshipMap.containsKey(acr.Contact.AccountId)) {
                member.relationshipNature =  relationshipMap.get(acr.Contact.AccountId).RelationshipType__c;
            }
            if(acr.Contact.AccountId.equals(accRecordId)) {
            	addMembersIntoGroupMembers(member,groupMembers);
                continue;
            }
            groupMembers.add(member);
            
        }
        HouseholdMembersWrapper groupJson= new HouseholdMembersWrapper();
        groupJson.count = String.valueOf(counter);
        groupJson.members = groupMembers;
        return groupJson;
        }
        catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }

    }

    private static void addMembersIntoGroupMembers(HouseholdMemberWrapper member, List<HouseholdMemberWrapper> groupMembers){
        member.relationshipNature = 'Self';
        if(groupMembers.size() >= 1) {
            groupMembers.add(0, member);
        } else {
            groupMembers.add(member); 
        }
    }
    
    private static Boolean isGenderAccessible(SObjectAccessDecision securityDecision, String field){
        Boolean isGender = false;
        if(securityDecision.getRemovedFields().get('Contact') != null && securityDecision.getRemovedFields().get('Contact').contains(field)){
            isGender = true;
        }
        return isGender;
    }

    private static List<Relationship__c> getRelationshipDetails(String hhRecordId, String accRecordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhRecordId, Account.class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accRecordId, Account.class);
        SObjectAccessDecision  securityDecision = Security.stripInaccessible(
            AccessType.READABLE,[
                SELECT AccountOne__c, AccountTwo__c, RelationshipType__c
                FROM Relationship__c 
                WHERE AccountTwo__c=:String.escapeSingleQuotes(accRecordId) 
                AND Primary_Household__c=:String.escapeSingleQuotes(hhRecordId)
            ], false);
        if(securityDecision.getRemovedFields().get('Relationship__c') != null) {
            return new List<Relationship__c>();
        }
       return securityDecision.getRecords();
    }
    
    private static SObjectAccessDecision getHouseholdMembersDetails(String hhRecordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhRecordId, Account.class);
        SObjectAccessDecision  securityDecision  = Security.stripInaccessible(
                AccessType.READABLE,
                [ 
                    SELECT Id, AccountId, ContactId, Contact.name, Contact.AccountId, Contact.Birthdate, Contact.ClientIdentifier__c,
                    Contact.Gender__c, Contact.IsDeathNotificationReceived__c, Contact.DeathDate__c , FinServ__Primary__c, Roles,
                    Contact.Account.RecordType.Name, Contact.Account.Age__c, Contact.Account.PreferredFirstName__c
		            FROM AccountContactRelation  
                    WHERE AccountId = :String.escapeSingleQuotes(hhRecordId) 
                    AND IsActive = true 
                    AND FinServ__PrimaryGroup__c = true
                ]
            );
        
       return securityDecision;
    }
    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : HouseholdMemberWrapper
    */
    public with sharing class HouseholdMembersWrapper {
        /**
        * @description count
        */
        @AuraEnabled
        public String count;
        /**
        * @description HouseholdMemberWrapper
        */
        @AuraEnabled
        public HouseholdMemberWrapper[] members;
    }

    /**
    * @description This inner class is used to make group member Wrapper JSON
    * @name : HouseholdMemberWrapper
    */
    public with sharing class HouseholdMemberWrapper {
        /**
        * @description relationshipNature
        */
        @AuraEnabled
        public String relationshipNature {get;set;}
        /**
        * @description name
        */
        @AuraEnabled
        public String name {get;set;}
        /**
        * @description id
        */
        @AuraEnabled
        public String id {get;set;}
        /**
        * @description url
        */
        @AuraEnabled
        public String url {get;set;}
        /**
        * @description recordTypeName
        */
        @AuraEnabled
        public String recordTypeName {get;set;}
        /**
        * @description gender
        */
        @AuraEnabled
        public String gender {get;set;}
        /**
        * @description birthDate
        */
        @AuraEnabled
        public Date birthDate {get;set;}
        /**
        * @description age
        */
        @AuraEnabled
        public String age {get;set;}
        /**
        * @description deceased
        */
        @AuraEnabled
        public Boolean deceased {get;set;}
        /**
        * @description deceasedDate
        */
        @AuraEnabled
        public Date deceasedDate {get;set;}
        /**
        * @description preferredName
        */
        @AuraEnabled
        public String preferredName {get;set;}
    } 
}