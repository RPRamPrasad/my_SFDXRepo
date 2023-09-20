/**
@author Team Atlas
@owner Team Atlas
@name UTIL_HouseholdC2CRelationship
@CreateDate 7/28/2021
@description This class is used by HouseholdC2C members
@version 1.0
*/

public with sharing class UTIL_HouseholdC2CRelationship {
    private static final String CLASS_NAME='UTIL_HouseholdC2CRelationship';
    private static final String C2C_RELATIONSHIP_INDIVIDUAL_TO_INDIVIDUAL ='Individual-Individual';
    private static final String C2C_RELATIONSHIP_INDIVIDUAL_TO_ORGANIZATION ='Individual-Organization';
    private static final String C2C_RELATIONSHIP_ORGANIZATION_TO_INDIVIDUAL ='Organization-Individual';
    private static final String C2C_RELATIONSHIP_ORGANIZATION_TO_ORGANIZATION ='Organization-Organization';

    /**
    * @description This method is used to get relationship record
    * @name : findHouseholdC2C
    * @param accId : Account Id
    * @return List<Relationship__c> : list of relationship records of household members
    */
    @AuraEnabled(cacheable=false)
    public static MembershipWrap findHouseholdMembers(String accId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accId, Account.class);
        MembershipWrap mbrWrap = new MembershipWrap();
        List<Relationship__c> c2cRelatioship = new List<Relationship__c>();
        try{
            User currentUser = getLoggedInUser(userInfo.getUserId());
            List<Contact> contData = Security.stripInaccessible(AccessType.READABLE,[
                SELECT Id, Name, Account.Name, Account.FirstName, Account.MiddleName, Account.LastName, Account.Suffix,Gender__c,
                AccountId,Account.RecordType.Name,Account.clientIdentifier__c,Account.PersonBirthdate,Account.Age__c
                FROM Contact
                WHERE Id IN (
                        SELECT ContactId
                        FROM AccountContactRelation
                        WHERE AccountId = :String.escapeSingleQuotes(accId) AND IsActive = true AND FinServ__PrimaryGroup__c = true
                    )  ORDER BY Account.Name ASC ]).getRecords();
            Set<Id> relationId = new Set<Id>();
            Map<String,String> memberMapping = new Map<String,String>();
            if(contData != null && contData.size() > 0){
                for(Contact acId:contData){
                    relationId.add(acId.AccountId);
                }
            }
            c2cRelatioship =  Security.stripInaccessible(AccessType.READABLE,
                [   SELECT Id, AccountTwo__r.Name,AccountOne__r.Name, RelationshipType__c
                    FROM Relationship__c
                    WHERE AccountTwo__r.id IN : relationId ]).getRecords();
            mbrWrap.conRecs = contData;
            if(c2cRelatioship != null){
                for(Relationship__c relation:c2cRelatioship){
                    String nameStr = '';
                    nameStr = relation.AccountTwo__r.Name + '_' + relation.AccountOne__r.Name;
                    memberMapping.put(nameStr,relation.RelationshipType__c);
                }
            }
            mbrWrap.c2cmbrRelationship = memberMapping;
            mbrWrap.recordTypePickListMap =  UTIL_HouseholdC2CRelationship.getOptionValues();   
            mbrWrap.userId = currentUser.Associate_ID__c;                                    
        }catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME,'findHouseholdC2C', System.LoggingLevel.ERROR);
        } 
        return mbrWrap;
    } 

    /**
     * @description Upsert C2C Relationship
     * @param responseBody 
     */
    @AuraEnabled
    public static void upsertC2CRelationship(String responseBody) {
        AP_C2CRelationshipAggregatorResponse custRelAggtRes = AP_C2CRelationshipAggregatorResponse.parse(responseBody);
        List<Relationship__c> listofC2CRelationshipRecords = HLPR_C2CRelationshipAggregatorResponse.getC2CRelationshipFromAggregatortResponse(custRelAggtRes.getDataList());
        UTIL_C2CRelationshipDAO.upsertC2CRelationships(listofC2CRelationshipRecords);
    } 

    private static User getLoggedInUser(String userId){
        List<User> loggedInUser = Security.stripInaccessible(AccessType.READABLE,[select Id, Name, Associate_ID__c from user where Id =:userId limit 1]).getRecords();
        return loggedInUser.get(0);
    }

    private static Map<string,List<RecordTypeRelation>> getOptionValues(){
        List<String> optionCategory = new List<String>();
        optionCategory.add(C2C_RELATIONSHIP_INDIVIDUAL_TO_INDIVIDUAL);
        optionCategory.add(C2C_RELATIONSHIP_INDIVIDUAL_TO_ORGANIZATION);
        optionCategory.add(C2C_RELATIONSHIP_ORGANIZATION_TO_INDIVIDUAL);
        optionCategory.add(C2C_RELATIONSHIP_ORGANIZATION_TO_ORGANIZATION);
        Map<string,List<RecordTypeRelation>> recordTypeRelationMap= new  Map<string,List<RecordTypeRelation>>();
        List<CM_C2C_Relationship_Mapping__mdt> mappingForC2COptions = new List<CM_C2C_Relationship_Mapping__mdt>();

        mappingForC2COptions = Security.stripInaccessible(AccessType.READABLE,[select Category__c,Label__c,Value__c  from CM_C2C_Relationship_Mapping__mdt where Category__c IN:optionCategory]).getRecords();
        for(CM_C2C_Relationship_Mapping__mdt singleOption:mappingForC2COptions){
            RecordTypeRelation recRelation = new RecordTypeRelation();
            recRelation.label = singleOption.Label__c;
            recRelation.value = singleOption.Value__c;
            if(recordTypeRelationMap.containsKey(singleOption.Category__c)){
                recordTypeRelationMap.get(singleOption.Category__c).add(recRelation);
            }else{
                List<RecordTypeRelation> recRelationLst = new List<RecordTypeRelation>();
                recRelationLst.add(recRelation);
                recordTypeRelationMap.put(singleOption.Category__c, recRelationLst);
            }
        }
        return recordTypeRelationMap;
    }

    /**
     * @description Membership Wrap
     */
    public with sharing class MembershipWrap{
        /**
         * @description getters and setters of the property conRecs
         * @return List<contact>
         */    
        @AuraEnabled
        public List<contact> conRecs {get;set;} 

        /**
         * @description getters and setters of the property c2cmbrRelationship
         * @return Map<String,String>
         */
        @AuraEnabled
        public Map<String,String> c2cmbrRelationship {get;set;} 

        /**
         * @description getters and setters of the property recordTypePickListMap
         * @return Map<string,List<RecordTypeRelation>>
         */
        @AuraEnabled
        public  Map<string,List<RecordTypeRelation>> recordTypePickListMap {get;set;}

        /**
         * @description getters and setters of the property userId
         * @return String
         */
        @AuraEnabled
        public String userId {get;set;}
    }

    /**
    * @description RecordType Relation
    */
    public with sharing class RecordTypeRelation{

        /**
         * @description getters and setters of the property label
         */
        @AuraEnabled
        public String label {get;set;} 

        /**
         * @description getters and setters of the property value
         */
        @AuraEnabled
        public String value {get;set;} 
    }
}
