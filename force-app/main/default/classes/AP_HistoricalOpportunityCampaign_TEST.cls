/**
  * @Name AP_HistoricalOpportunityCampaign_TEST
  * Date Created :06/10/2019
  * @Author ITIC
  * @description This is test class for AP_HistoricalOpportunityCampaign 
  */
  @isTest(seeAllData = false)
  public with sharing class AP_HistoricalOpportunityCampaign_TEST {
      private static List<Account> accountList;
      private static List<Opportunity> opportunityRecordList;
  
      @TestSetup
      static void testSetupData(){                          
          List<User> userList = new List<User>();
          User agentUser = TestDataFactory_User_Wrapper.generateAgentUser('OO1A','OOOO1111111');
          agentUser.UserExternalID__c = 'OOOO1111111A';
          agentUser.UserType__c = 'Agent';
          agentUser.SubUserType__c = 'Agent';
          userList.add(agentUser);
                                                          
          User salesLeaderUser = TestDataFactory_User_Wrapper.generateSalesLeaderUser('OO1S','OOOO1111111','OOOO111111T');
          salesLeaderUser.UserExternalID__c = 'OOOO1111111S';
          userList.add(salesLeaderUser);
  
          User proxyUser = TestDataFactory_User_Wrapper.generateProxyUser('OO1AP','OOOO1111111');
          proxyUser.UserExternalID__c = 'OOOO1111111P';
          proxyUser.UserType__c = 'Agent Proxy';
          userList.add(proxyUser);
          insert userList;
  
          accountList = new List<Account>();
          for (Integer i=1;i<=3;i++){
              Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
              account.ClientIdentifier__c = 'OO11111111'+i;
              accountList.add(account);
          } 
          TestDataFactory_Account.byPassAccountBeforeTrigger();
          TestDataFactory_Account.insertAccount(accountList);
          updatePersonContact(accountList[2]);
          createOpportunities(accountList);
      }
  
      private static void updatePersonContact(Account accountDeathNotified){
          Contact personContact = [Select Id,IsDeathNotificationReceived__c from Contact where AccountId=:accountDeathNotified.Id];
          personContact.IsDeathNotificationReceived__c = true;
          update personContact;
      }
  
      private static void createActivityTasks(String opportunityId,String userId){
          List<Task> taskList = new List<Task>();
          Task taskRecordInclude = new Task(WhatId=opportunityId,OwnerId=userId,ActivityDate=System.today().addDays(-3));
          taskList.add(taskRecordInclude);
          Task taskRecordExclude = new Task(WhatId=opportunityId,OwnerId=userId,ActivityDate=System.today().addDays(+3));
          taskList.add(taskRecordExclude);
          insert taskList;
      }
  
      private static void createOpportunities(List<Account> accountList){
          User proxyUser = [Select Id from User where UserExternalID__c='OOOO1111111P'];
          opportunityRecordList = new List<Opportunity>();
          for (Account acc: accountList){
              Opportunity opportunityRecord = TestDataFactory_Opportunity.generateOpportunity('TestReportOpp '+ acc.FirstName);
              opportunityRecord.AccountId = acc.Id;
              opportunityRecord.OwnerId = proxyUser.Id;
              opportunityRecord.StageName='Closed';
              opportunityRecord.LOB__c='Auto';
              opportunityRecord.Company__c='Mutual';
              opportunityRecord.OppClosedDateTime__c = DateTime.now().addDays(-30);
              opportunityRecordList.add(opportunityRecord);
          }
          Opportunity opportunityWithSameAccount = TestDataFactory_Opportunity.generateOpportunity('TestReportOpp '+ accountList[0].FirstName);
          opportunityWithSameAccount.AccountId = accountList[0].Id;
          opportunityWithSameAccount.OwnerId = proxyUser.Id;
          opportunityRecordList.add(opportunityWithSameAccount);
          insert opportunityRecordList;
      }
      private static AP_BatchReportRequest retrieveReportData(){
          AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
          return reportFieldValue.setBatchReportRequest('Batch_NeglectedAbandonedAutoOpportunity');
      }
      // This test methods verify Campaign and Campaign Members are created from Opportunity
      @isTest
      private static void testCampaignAndCampaignMemberCreationSingleOffice(){
          Opportunity opportunity1 = [Select Id from Opportunity where Name='TestReportOpp TestAccName1' and createddate= TODAY limit 1];
          User agentUser = [Select Id from User where UserExternalId__c='OOOO1111111A'];
         // System.runAs(agentUser){
              createActivityTasks(opportunity1.Id,agentUser.Id);
          //}*/
          System.runAs(TestDataFactory_User.getSysAdminUser()){
              Test.setCreatedDate(opportunity1.Id, DateTime.now().addMonths(-2));
              
              Opportunity opportunity2 = [Select Id from Opportunity where Name='TestReportOpp TestAccName2' and createddate= TODAY limit 1];
              Test.setCreatedDate(opportunity2.Id, DateTime.now().addMonths(-2));
              
              //List<Opportunity> opportunityList = [SELECT Id, OwnerId, Createddate, Owner.Alias, AccountId,IsAccountHealthSourced__c,Account.PersonContactId, Account.IsDeathNotificationReceived__pc,CampaignId FROM Opportunity WHERE StageName='Closed' AND LOB__c='Auto' AND CreatedDate = LAST_N_MONTHS:3 AND CreatedDate < LAST_N_MONTHS:2 AND IsAccountHealthSourced__c=false AND Company__c!='Standard'];
              List<Opportunity> opportunityList = [SELECT  Id, OwnerId, Owner.Alias,Owner.SubUserType__c,Owner.UserType__c, AccountId,Account.PersonContactId, Account.IsDeathNotificationReceived__pc,CampaignId FROM Opportunity WHERE Id IN (:opportunity1.id,:opportunity2.id)];
              Test.startTest();
                  AP_HistoricalOpportunityCampaign historicalCampaign = new AP_HistoricalOpportunityCampaign();
                  historicalCampaign.processOpportunityCampaign(opportunityList,retrieveReportData());
              Test.stopTest();
                  List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
                  system.assert(campaignList.size()==1,'campaign not created');
                  List<CampaignMember> campaignMemberList = [Select Id,ContactId,Status__c, Name from CampaignMember where CampaignId = :campaignList];
                  system.assert(campaignMemberList.size()==2, 'campaignMemberList size does not match');
                  for(CampaignMember member: campaignMemberList){
                      system.assert(member.ContactId!=null,'contact null');
                      system.assert(member.Status__c!=null,'status null');
                  }
          }
      }
      // This test method takes the input as two opportunities associated to single account, one Campaign and single campaign member is created 
      @isTest
      private static void testTwoOpportunityHavingSameAccount(){
          System.runAs(TestDataFactory_User.getSysAdminUser()){
              List<Opportunity> opportunityRecords = [Select Id,AccountId from Opportunity where Name='TestReportOpp TestAccName1' and createddate= TODAY limit 2];
              for(Opportunity opp:opportunityRecords){
                  Test.setCreatedDate(opp.Id, DateTime.now().addMonths(-3));
              }
              List<Opportunity> opportunityList = [SELECT Id, OwnerId, Owner.Alias,Owner.SubUserType__c,Owner.UserType__c, AccountId,IsAccountHealthSourced__c,Account.PersonContactId, 
                                                      Account.IsDeathNotificationReceived__pc FROM Opportunity 
                                                          WHERE Id = :opportunityRecords];
              Test.startTest();
                  AP_HistoricalOpportunityCampaign historicalCampaign = new AP_HistoricalOpportunityCampaign();
                  historicalCampaign.processOpportunityCampaign(opportunityList, retrieveReportData());
                  // Call processOpportunityCampaign again in order test non-duplicate campaign creation 
                  historicalCampaign.processOpportunityCampaign(opportunityList, retrieveReportData());
              Test.stopTest();
                  List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
                  system.assert(campaignList.size()==1,'Campaigns not created');
                  List<CampaignMember> campaignMemberList = [Select Id,Status__c,ContactId, Name from CampaignMember where CampaignId =:campaignList];
                  system.assert(campaignMemberList.size()==1,'campaignMemberList size does not match');
                  for(CampaignMember member: campaignMemberList){
                      system.assert(member.ContactId!=null,'contact null');
                      system.assert(member.Status__c!=null,'status null');
                  }
          }
      }
      
      @isTest
      private static void testCustomerWithDeathIndicatorTrue(){
          System.runAs(TestDataFactory_User.getSysAdminUser()){
          
          Opportunity opportunityRecord = [Select Id,AccountId from Opportunity where Name='TestReportOpp TestAccName3' and createddate= TODAY limit 1];
          List<Opportunity> opportunityList = [SELECT Id, OwnerId, Owner.Alias,Owner.SubUserType__c,Owner.UserType__c, AccountId,IsAccountHealthSourced__c,CampaignId,Account.PersonContactId, 
                                              Account.IsDeathNotificationReceived__pc FROM Opportunity 
                                              WHERE Id = :opportunityRecord.id]; 
          Test.startTest();
              AP_HistoricalOpportunityCampaign historicalCampaign = new AP_HistoricalOpportunityCampaign();
              historicalCampaign.processOpportunityCampaign(opportunityList, retrieveReportData());
          Test.stopTest();
          List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
          system.assert(campaignList.size()==1,'campaignList size does not match');
          List<CampaignMember> campaignMemberList = [Select Id,Status__c,ContactId, Name from CampaignMember where CampaignId IN :campaignList];
                  system.assert(campaignMemberList.size()==0,'campaignMemberList size does not match');
          }
      }
      
      @isTest
      private static void testAccountRelationshipExistingCustomer(){
          User agentUser = [Select Id, name, Alias, Servicing_Agent_Associate_ID__c from User where UserExternalId__c='OOOO1111111A'];
          Account acc = [Select Id,ClientIdentifier__c from Account where FirstName='TestAccName3' and ClientIdentifier__c='OO111111113' limit 1]; 
          
          System.runAs(TestDataFactory_User.getSysAdminUser()){
              TestDataFactory_Account.byPassAgentRoleBeforeTrigger();
              TestDataFactory_AgentRole.createAgentRole (agentUser, acc, 'Customer');
          
          List<Opportunity> opportunityList = [SELECT Id, OwnerId, Owner.Alias,Owner.SubUserType__c,Owner.UserType__c, AccountId,IsAccountHealthSourced__c,CampaignId,Account.PersonContactId, 
                                              Account.IsDeathNotificationReceived__pc FROM Opportunity 
                                              WHERE AccountId = :acc.id];
              Test.startTest();
                  AP_HistoricalOpportunityCampaign historicalCampaign = new AP_HistoricalOpportunityCampaign();
                  historicalCampaign.processOpportunityCampaign(opportunityList, retrieveReportData());
              Test.stopTest();
                  List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
                  system.assert(campaignList.size()==1,'campaignList size does not match');
          List<CampaignMember> campaignMemberList = [Select Id,Status__c,ContactId, Name from CampaignMember where CampaignId IN :campaignList];
                  system.assert(campaignMemberList.size()==0,'campaignMemberList size does not match');
          }
          }
  
          @isTest
          private static void testNoCampaignCreatedForNonAgencyUser(){
              User nonAgencyUser = [Select Id from User where Name='SYSTEM_USER_REC_OWNER' limit 1];
              Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName0');
              account.ClientIdentifier__c = 'OO111111110';
              insert account;
  
              Opportunity opportunity1 = TestDataFactory_Opportunity.generateOpportunity('TestReportOpp '+ account.FirstName);
              opportunity1.AccountId = account.Id;
              opportunity1.OwnerId = nonAgencyUser.Id;
              opportunity1.StageName='Closed';
              opportunity1.LOB__c='Auto';
              opportunity1.Company__c='Mutual';
              opportunity1.OppClosedDateTime__c = DateTime.now().addDays(-30);
              insert opportunity1;
              
              System.runAs(TestDataFactory_User.getSysAdminUser()){
                  Test.setCreatedDate(opportunity1.Id, DateTime.now().addMonths(-2));
                  
                  Opportunity opportunity2 = [Select Id from Opportunity where Name='TestReportOpp TestAccName2' and createddate= TODAY limit 1];
                  Test.setCreatedDate(opportunity2.Id, DateTime.now().addMonths(-2));
                  
                  //List<Opportunity> opportunityList = [SELECT Id, OwnerId, Createddate, Owner.Alias, AccountId,IsAccountHealthSourced__c,Account.PersonContactId, Account.IsDeathNotificationReceived__pc,CampaignId FROM Opportunity WHERE StageName='Closed' AND LOB__c='Auto' AND CreatedDate = LAST_N_MONTHS:3 AND CreatedDate < LAST_N_MONTHS:2 AND IsAccountHealthSourced__c=false AND Company__c!='Standard'];
                  List<Opportunity> opportunityList = [SELECT  Id, OwnerId, Owner.Alias,Owner.UserType__c,Owner.SubUserType__c, AccountId,Account.PersonContactId, Account.IsDeathNotificationReceived__pc,CampaignId FROM Opportunity WHERE Id IN (:opportunity1.id,:opportunity2.id)];
                  Test.startTest();
                      AP_HistoricalOpportunityCampaign historicalCampaign = new AP_HistoricalOpportunityCampaign();
                      historicalCampaign.processOpportunityCampaign(opportunityList,retrieveReportData());
                  Test.stopTest();
                      List<Campaign> campaignList = [Select Id, Name from Campaign where startdate = TODAY AND Source__c='Report'];
                      system.assert(campaignList.size()==1,'campaign not created');
                      List<CampaignMember> campaignMemberList = [Select Id,ContactId,Status__c, Name from CampaignMember where CampaignId = :campaignList];
                      system.assert(campaignMemberList.size()==1, 'campaignMemberList size does not match');
                      
              }
          }
  }
  