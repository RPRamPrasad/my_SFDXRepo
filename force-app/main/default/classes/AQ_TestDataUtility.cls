/**
@author Team Skynet
@name AQ_TestDataUtility
@createDate 12/7/2022
@description Test Data Utility for Agent Queue related tests
*/
@isTest
(seeAllData=false)
public with sharing class AQ_TestDataUtility {

    @TestVisible private static final String OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    
    
    @TestVisible private static void createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',BillingAddressType__c='US',BillingCity='Phoenix',ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible private static Opportunity getOpportunity(){
        return [SELECT Id FROM Opportunity WHERE  Account.ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible private static Task getTask(){
        return [SELECT Id FROM Task WHERE  Account.ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }
    
    @TestVisible private static Lead getLead(Id ownerId){
        return [SELECT Id FROM Lead WHERE ownerId = :ownerId];
    }
    
    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole; 
    }
    
    @TestVisible private static void createLead(Id ownerId){
        Lead leadRec = new Lead (LastName='LeadTest', SetDoNotSolicit__c = '1', ownerId = ownerId);
        insert leadRec;
    }
    
    @TestVisible private static void createTask(Id ownerId, Id whoId, Id whatId){
        Task taskRecord = new Task();
        taskRecord.Subject = 'Test Subject';
        taskRecord.ActivityDate = Date.today();
        taskRecord.Priority = 'Low';
        taskRecord.Status = TaskHandlerConstants.TASK_STATUS_NOT_STARTED;
        taskRecord.Description = 'Test Desc';
        taskRecord.WhoId = whoId;
        taskRecord.WhatId = whatId;
        taskRecord.OwnerId = ownerId;
        taskRecord.Task_Type__c = 'Service';
		insert taskRecord;
    }
    
    @TestVisible private static void createOpportunity(Account accountRecord, User userRecord){
        Opportunity opp = new Opportunity();
        opp.AccountId = accountRecord.Id;
        opp.LOB__c = 'Auto';
        opp.ContactId = accountRecord.PersonContactId;
        opp.OwnerId = userRecord.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        opp.RecordTypeId = OPPORTUNITY_RECORD_TYPE_ID_OPPORTUNITY_MANAGEMENT;
        insert opp;
    }
    
}