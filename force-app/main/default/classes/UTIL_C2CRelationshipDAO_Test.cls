/**
@Author Team Loco Motivated
@Name UTIL_C2CRelationshipDAO_Test
@CreateDate 04/04/2017
@description Common class to access various Relatioships operations for various Processor Test.
@Version 1.0
*/
@isTest(seeAllData=false)
public class UTIL_C2CRelationshipDAO_Test {
    
    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static final String CLIENT_IDENTIFIER1='IAMCLIENT13';
    private static final String CLIENT_IDENTIFIER2='IAMCLIENT17';
    private static final String AGENT1_ASSOCID='IAMASSCID1A';    
    private static Account accrecord;
    private static Account accrecord1;
    private static Account accrecord2;
    private static CS001_ByPassTriggerAll__c accountbypass;
    private static List<Account> accountLst = new List<Account>();
    
    /**
     * @description This method will create test data
     */
    public static void setup() {
        systemUser=UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert systemUser;
        insert testAPIUser;
        
        accountbypass = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert accountbypass;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        accrecord = new Account(FirstName='Ftest1',LastName='Ltest1',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        accrecord1 = new Account(FirstName='Ftest2',LastName='Ltest2',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER1);
        accrecord2 = new Account(FirstName='Ftest3',LastName='Ltest3',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER2);
        accountLst.add(accrecord);
        accountLst.add(accrecord1);
        accountLst.add(accrecord2);
    }
    
    @isTest
    static void testSingleRelationshipForInsert(){
        Relationship__c relatioshipRecord= new Relationship__c();
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            relatioshipRecord.AccountTwo__c=accrecord.id;
            relatioshipRecord.AccountOne__c=accrecord1.id;
            relatioshipRecord.RelationshipType__c='Parent';
            relatioshipRecord.RelationshipIdentifier__c=accrecord.ClientIdentifier__c+'~'+accrecord1.ClientIdentifier__c;
            System.runAs(testAPIUser) {
                UTIL_C2CRelationshipDAO.insertRelationship(relatioshipRecord);           
            }
            Test.stopTest();   
        }
        
        Relationship__c testrelatioship=[select AccountOne__c,AccountTwo__c,RelationshipIdentifier__c,RelationshipType__c
                                         from Relationship__c where id=:relatioshipRecord.Id];
        system.assertEquals(relatioshipRecord.AccountOne__c, testrelatioship.AccountOne__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(relatioshipRecord.AccountTwo__c, testrelatioship.AccountTwo__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(relatioshipRecord.RelationshipIdentifier__c, testrelatioship.RelationshipIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(relatioshipRecord.RelationshipType__c, testrelatioship.RelationshipType__c, 'Expected parameter is not equals to the actual parameter');
    }
    
    @isTest
    static void testRelationshipListForInsert(){
        List<Relationship__c> relatioshipList= new List<Relationship__c>();
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            relatioshipList.add(createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent'));
            relatioshipList.add(createC2CRelationships(accrecord.ClientIdentifier__c, accrecord2.ClientIdentifier__c,'Spouse'));
            System.runAs(testAPIUser) {
                UTIL_C2CRelationshipDAO.insertC2CRelationships(relatioshipList);           
            }
            Test.stopTest();   
        }
        
        List<Relationship__c> testrelatioships =[select AccountOne__c,AccountTwo__c,RelationshipIdentifier__c,RelationshipType__c
                                         from Relationship__c where id=:relatioshipList];
        for(Relationship__c relationshipRecord :testrelatioships){
            if(relationshipRecord.RelationshipType__c.equalsIgnoreCase('Parent')){
                system.assertEquals(accrecord1.id, relationshipRecord.AccountOne__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(accrecord.id, relationshipRecord.AccountTwo__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(accrecord.ClientIdentifier__c+'~'+accrecord1.ClientIdentifier__c, relationshipRecord.RelationshipIdentifier__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals('Parent', relationshipRecord.RelationshipType__c, 'RelationshipType is not Parent');                
            }
            if(relationshipRecord.RelationshipType__c.equalsIgnoreCase('Spouse')){
                system.assertEquals(accrecord2.id, relationshipRecord.AccountOne__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(accrecord.id, relationshipRecord.AccountTwo__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(accrecord.ClientIdentifier__c+'~'+accrecord2.ClientIdentifier__c, relationshipRecord.RelationshipIdentifier__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals('Spouse', relationshipRecord.RelationshipType__c, 'RelationshipType is not Spouse');
            }
        }
    }
    
    @isTest
    static void testRelationshipForUpdate(){
        Relationship__c relatioshipRecord;
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            relatioshipRecord= createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent');
            insert relatioshipRecord;
            relatioshipRecord.RelationshipType__c='Father';
            System.runAs(testAPIUser) {
                UTIL_C2CRelationshipDAO.updateRelationship(relatioshipRecord);           
            }
            Test.stopTest();   
        }
        
        Relationship__c testrelatioship=[select RelationshipType__c from Relationship__c where id=:relatioshipRecord.Id];
        system.assertEquals('Father', testrelatioship.RelationshipType__c, 'Expected RelationshipType is not equals to the actual RelationshipType');
    }
    
    @isTest
    static void testRelationshipForDelete(){
        List<Relationship__c> relatioshipRecord1= new List<Relationship__c>();
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            Relationship__c relatioshipRecord=createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent');
            insert relatioshipRecord;
            relatioshipRecord1.add(relatioshipRecord);
            UTIL_C2CRelationshipDAO.deleteCustomerRelationships(relatioshipRecord1);
            
            try{
                Relationship__c testRelationship = [select Id from Relationship__c where id=:relatioshipRecord.Id];
                system.assertEquals(testRelationship, null, 'Relationship__c is not deleted');
            }catch(QueryException ex){
                system.assert(true, 'Assertion returns false'); 
            }
            Test.stopTest(); 
            
        }
    }
    
    @isTest
    static void testDualRelationshipForDelete(){
        List<Relationship__c> relatioshipRecord2= new List<Relationship__c>();
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            Relationship__c relatioshipRecord= createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent');
            Relationship__c relatioshipRecord1= createC2CRelationships(accrecord1.ClientIdentifier__c, accrecord.ClientIdentifier__c,'Son');
            relatioshipRecord2.add(relatioshipRecord);
            relatioshipRecord2.add(relatioshipRecord1);
            insert relatioshipRecord2;
            
            UTIL_C2CRelationshipDAO.deleteCustomerRelationships(relatioshipRecord2);
            
            try{
                Relationship__c testRelationship = [select Id from Relationship__c where id=:relatioshipRecord.Id];
                system.assertEquals(testRelationship, null, 'Relationship__c is not deleted');
            }catch(QueryException ex){
                system.assert(true, 'Assertion returns false'); 
            }
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void testDualRelationshipException(){
        List<Relationship__c> relatioshipRecordListToDelete= new List<Relationship__c>();
        List<Relationship__c> deletingrelatioshipRecords= new List<Relationship__c>();
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            Relationship__c relatioshipRecord1= createC2CRelationships(accrecord1.ClientIdentifier__c, accrecord.ClientIdentifier__c,'Son');
            Relationship__c relatioshipRecord2= new Relationship__c(AccountTwo__c=accrecord1.id,AccountOne__c=accrecord.id,RelationshipType__c='Son',
                                    								RelationshipIdentifier__c=accrecord1.ClientIdentifier__c+'~');
            
            relatioshipRecordListToDelete.add(createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent'));
            relatioshipRecordListToDelete.add(relatioshipRecord1);
            relatioshipRecordListToDelete.add(relatioshipRecord2);
            insert relatioshipRecordListToDelete;
            deletingrelatioshipRecords.add(relatioshipRecord1);
            deletingrelatioshipRecords.add(relatioshipRecord2);
            delete deletingrelatioshipRecords;
            UTIL_C2CRelationshipDAO.deleteCustomerRelationships(relatioshipRecordListToDelete);            
            Test.stopTest(); 
            
            ExceptionLog__c results = [SELECT IsHandled__c,Class__c,Method__c,Exception_Message__c  FROM ExceptionLog__c 
                                       where class__c like '%UTIL_RelationshipDAO%' limit 1];
            System.assertEquals('UTIL_RelationshipDAO' , results.Class__c, 'Class__c should be UTIL_RelationshipDAO');
            System.assertEquals('deleteCustomerRelationships', results.Method__c, 'Method__c should be deleteCustomerRelationships');
            System.assertEquals(true, results.IsHandled__c, 'IsHandled__c should be true'); 
            System.assertEquals('Records already deleted: '+relatioshipRecord1.id+','+relatioshipRecord2.id, results.Exception_Message__c, 'Exception_Message__c should be equals to the given message');
        }
    }
    
    @isTest
    static void testRelationshipForGivenRecordId(){
        Relationship__c relatioshipRecord;
        setup();        
        system.runAs(systemUser){
            insert  accountLst;
            Test.startTest();
            relatioshipRecord= createC2CRelationships(accrecord.ClientIdentifier__c, accrecord1.ClientIdentifier__c,'Parent');
            insert relatioshipRecord;
            System.runAs(testAPIUser) {
                Relationship__c expectedRelationship= UTIL_C2CRelationshipDAO.getC2CRelationshipRecord(relatioshipRecord.id);
                
                system.assertEquals('Parent', expectedRelationship.RelationshipType__c, 'RelationshipType should be Parent');
                system.assertEquals(accrecord.Id, expectedRelationship.AccountTwo__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(accrecord1.Id, expectedRelationship.AccountOne__c, 'Expected parameter is not equals to the actual parameter');
            }
            Test.stopTest();   
        }
    }
    
    
    //This method is used to create createC2CRelationships
    /**
     * @description Create C2C Relationships
     * @param customerId
     * @param relationshipWith
     * @param relationNature
     * @return Relationship__c
     */
    public static Relationship__c createC2CRelationships(String customerId, String relationshipWith,string relationNature){
        return new Relationship__c(AccountTwo__r=new account(ClientIdentifier__C=customerId),
                                                   				AccountOne__r=new account(ClientIdentifier__C=relationshipWith),
                                                   				RelationshipType__c=relationNature,
                                                   				RelationshipIdentifier__c=customerId+'~'+relationshipWith);
    }
}