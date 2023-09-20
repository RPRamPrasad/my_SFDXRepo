@isTest (seeAllData=false)
public with sharing class AP_ServiceCampaigns_Test {
    private static List<Service_Campaign__c> serviceCampaignList;
    private static List<Account> accountList;

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
          serviceCampaignList = new List<Service_Campaign__c>();
          accountList = new List<Account>();
          for (Integer i=1;i<=3;i++){
              Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
              account.ClientIdentifier__c = 'OO11111111'+i;
              accountList.add(account);
              Service_Campaign__c serviceCampaign = new Service_Campaign__c(PolicyNumber__c='TESTRISK'+i,State__c='IL',
                                              CampaignName__c='Removal of Withdrawal from Use January 2023', 
                                              CampaignStartDate__c=System.today()+10,ToBeProcessed__c=True);
              serviceCampaignList.add(serviceCampaign);
          } 
          TestDataFactory_Account.byPassAccountBeforeTrigger();
          TestDataFactory_Account.insertAccount(accountList);
          insert serviceCampaignList;
          
    }
    //test the service campaign creation using the batch
    @isTest       
    private static void testServiceCampaignCreationWithAdditionalInformation() {
        List<Account> account_List;
        List<Service_Campaign__c> service_CampaignList;
        List<Service_Campaign__c> serviceCampaignUpdateList =new List<Service_Campaign__c>();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c from User where UserExternalId__c='OOOO1111111A'];
        account_List = [SELECT Id, Primary_Household__pc, PersonContactId,ClientIdentifier__c FROM Account WHERE ClientIdentifier__c like 'OO1111111%' limit 3];
        for (Account acc:AccountList){
            TestDataFactory_AgentRole.createAgentRole(agentUser,acc,'Customer');
        }
        
        createPolicyData(agentUser,account_List);

        System.runAs(sysAdminUser) {
        service_CampaignList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,State__c, AdditionalInformation__c from Service_Campaign__c
                                                        where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        for(Service_Campaign__c serviceCampaignRecord: service_CampaignList){
            serviceCampaignRecord.AdditionalInformation__c='Additional Information Text';
            serviceCampaignUpdateList.add(serviceCampaignRecord);
        }    
        update serviceCampaignUpdateList;                                                    
        
        Test.startTest();
        AP_ServiceCampaigns processServiceCampaign = new AP_ServiceCampaigns();
        processServiceCampaign.processServiceCampaign(service_CampaignList,service_CampaignList[0].CampaignName__c,
                                                      service_CampaignList[0].CampaignStartDate__c);
        Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id,Name,Status,Source__c,StartDate,type,External_Campaign_ID__c,recordtype.developername from Campaign Where Name=:service_CampaignList[0].CampaignName__c];
        system.assertEquals(1, campaignList.size(), 'Campaigns not created');
        system.assertEquals(campaignList[0].Status,'Fulfillment Pending','status null');
        system.assertEquals(campaignList[0].Source__c,'Report','Source not report');
        system.assertEquals(campaignList[0].type,'Customer/Prospect','type do not match'); //OOOO1111111
        system.assertEquals(campaignList[0].recordtype.developername,'Service','record is not service');
        system.assertEquals(campaignList[0].StartDate,service_CampaignList[0].CampaignStartDate__c,'StartDate do not match');
        system.assert(campaignList[0].External_Campaign_ID__c==agentUser.Servicing_Agent_Associate_ID__c+'IL'+generateExternalId(),'externalId do not match');

        List<CampaignMember> campaignMemberList = [Select Id,ContactId,CampaignId,Status__c,ExternalData__c from CampaignMember where CampaignId=:campaignList[0].id];
        system.assert(campaignMemberList.size()==2,'campaignMemberList size does not match');
        
        for(CampaignMember member: campaignMemberList){
            system.assert(member.ContactId!=null,'contact null');
            system.assertEquals(member.ExternalData__c,'TextOnly: Additional Information Text','No Policydata');
        }
        List<Service_Campaign__c> serviceCampaignProcessedList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,
                                                                AdditionalInformation__c from Service_Campaign__c
                                                                where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        system.assertEquals(serviceCampaignProcessedList[0].ToBeProcessed__c,false,'Service Campaign record not marked completed');
    }

    @isTest       
    private static void testServiceCampaignCreationWithPolicyData() {
        List<Account> accountList;
        List<Service_Campaign__c> serviceCampaignList;
        List<Service_Campaign__c> serviceCampaignUpdateList;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c from User where UserExternalId__c='OOOO1111111A'];
        accountList = [SELECT Id, Primary_Household__pc, PersonContactId,ClientIdentifier__c FROM Account WHERE ClientIdentifier__c like 'OO1111111%' limit 3];
        for (Account acc:AccountList){
            TestDataFactory_AgentRole.createAgentRole(agentUser,acc,'Customer');
        }
        System.runAs(sysAdminUser) {
        InsurancePolicy policyRecord = new InsurancePolicy(Servicing_Agent__c=agentUser.Id,NameInsuredId=accountList[1].id,AgreDisplayPartyName__c='TESTNAME',
                                 PolicyType='Life',PolicyName='Life Insurance', AgreAccessKey__c='TESTRISK'+3,Name='100 0000-000-33');
        
        insert policyRecord;
        InsurancePolicyParticipant participantRecord = new InsurancePolicyParticipant(PrimaryParticipantAccountId=accountList[1].Id,InsurancePolicyId=policyRecord.id,Role='Named Insured');
        insert participantRecord;
        InsurancePolicyAsset assetRecord = new InsurancePolicyAsset(AssetName='1997 Gmc Suburban Sport Wg',RiskStatusText__c='In Force', InsurancePolicyId=policyRecord.id);
        insert assetRecord;
        Service_Campaign__c serviceCampaign = new Service_Campaign__c(PolicyNumber__c='TESTRISK'+3,State__c='IL',
                                              CampaignName__c='Removal of Withdrawal from Use January 2023', 
                                              CampaignStartDate__c=System.today()+10,ToBeProcessed__c=True);
        
        
        createPolicyData(agentUser,accountList);
        }
        System.runAs(sysAdminUser) {
        serviceCampaignList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,State__c, AdditionalInformation__c from Service_Campaign__c
                                                        where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        Test.startTest();
        AP_ServiceCampaigns processServiceCampaign = new AP_ServiceCampaigns();
        processServiceCampaign.processServiceCampaign(serviceCampaignList,serviceCampaignList[0].CampaignName__c,
                                                      serviceCampaignList[0].CampaignStartDate__c);
        Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id,Name,Status,Source__c,StartDate,type,External_Campaign_ID__c,recordtype.developername from Campaign Where Name=:serviceCampaignList[0].CampaignName__c];
        system.assertEquals(1, campaignList.size(), 'Campaigns not created');
        system.assertEquals(campaignList[0].Status,'Fulfillment Pending','status null');
        system.assertEquals(campaignList[0].Source__c,'Report','Source not report');
        system.assertEquals(campaignList[0].type,'Customer/Prospect','type do not match'); //OOOO1111111
        system.assertEquals(campaignList[0].recordtype.developername,'Service','record is not service');
        system.assertEquals(campaignList[0].StartDate,serviceCampaignList[0].CampaignStartDate__c,'StartDate do not match');
        system.assert(campaignList[0].External_Campaign_ID__c==agentUser.Servicing_Agent_Associate_ID__c+'IL'+generateExternalId(),'externalId do not match');

        List<CampaignMember> campaignMemberList = [Select Id,ContactId,CampaignId,Status__c,ExternalData__c from CampaignMember where CampaignId=:campaignList[0].id];
        system.assert(campaignMemberList.size()==2,'campaignMemberList size does not match');
        
        for(CampaignMember member: campaignMemberList){
            system.assert(member.ContactId!=null,'contact null');
            system.assert(member.ExternalData__c!=null,'No Policydata');
        }
        List<Service_Campaign__c> serviceCampaignProcessedList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,
                                                                AdditionalInformation__c from Service_Campaign__c
                                                                where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        system.assertEquals(serviceCampaignProcessedList[0].ToBeProcessed__c,false,'Service Campaign record not marked completed');
    }

    @isTest       
    private static void testTwoPolicyOneAccount() {
        List<Account> accountList;
        List<Service_Campaign__c> serviceCampaignList;
        List<Service_Campaign__c> serviceCampaignUpdateList;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        
        
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c from User where UserExternalId__c='OOOO1111111A'];
        accountList = [SELECT Id, Primary_Household__pc, PersonContactId,ClientIdentifier__c FROM Account WHERE ClientIdentifier__c like 'OO1111111%' limit 3];
        for (Account acc:AccountList){
            TestDataFactory_AgentRole.createAgentRole(agentUser,acc,'Customer');
        }
        
        createPolicyData(agentUser,accountList);

        System.runAs(sysAdminUser) {
        serviceCampaignList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,State__c, AdditionalInformation__c from Service_Campaign__c
                                                        where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        AP_ServiceCampaigns processServiceCampaign = new AP_ServiceCampaigns();
        processServiceCampaign.processServiceCampaign(serviceCampaignList,serviceCampaignList[0].CampaignName__c,
                                                      serviceCampaignList[0].CampaignStartDate__c);
        Test.startTest();
        AP_ServiceCampaigns processServiceCampaignTwo = new AP_ServiceCampaigns();
        processServiceCampaignTwo.processServiceCampaign(serviceCampaignList,serviceCampaignList[0].CampaignName__c,
                                                      serviceCampaignList[0].CampaignStartDate__c);
        Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id,Name,Status,Source__c,StartDate,type,External_Campaign_ID__c,recordtype.developername from Campaign Where Name=:serviceCampaignList[0].CampaignName__c];
        system.assertEquals(1, campaignList.size(), 'Campaigns not created');
        
        List<CampaignMember> campaignMemberList = [Select Id,ContactId,CampaignId,Status__c,ExternalData__c from CampaignMember where CampaignId=:campaignList[0].id];
        system.assert(campaignMemberList.size()==2,'campaignMemberList size does not match');
        
        List<Service_Campaign__c> serviceCampaignProcessedList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,
                                                                AdditionalInformation__c from Service_Campaign__c
                                                                where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        system.assertEquals(serviceCampaignProcessedList[0].ToBeProcessed__c,false,'Service Campaign record not marked completed');

        List<ExceptionLog__c> logRecordList = [SELECT Id, Exception_Message__c, Method__c, Exception_Type__c FROM ExceptionLog__c WHERE Exception_Message__c LIKE'%DUPLICATE_VALUE%' order by createddate desc limit 10];
        system.assert(logRecordList.size()==0, 'Duplicate campaign member exception exists');
        
        
        for(CampaignMember member: campaignMemberList){
            system.assert(member.ContactId!=null,'contact null');
            system.assert(member.ExternalData__c!=null,'No Policydata');
        }
   
    }

    private static void createPolicyData (User agent, List<Account> accountList){
        List<InsurancePolicy> policyList = new List<InsurancePolicy>();
        for(Integer i=0;i<3;i++){
            policyList.add(new InsurancePolicy(Servicing_Agent__c=agent.Id,NameInsuredId=accountList[i].id,AgreDisplayPartyName__c='TESTNAME',
                                 PolicyType='Auto',PolicyName='Private Passenger', AgreAccessKey__c='TESTRISK'+i,Name='100 0000-000-22'));
        }
        insert policyList;
        List<InsurancePolicyParticipant> participantList = new List<InsurancePolicyParticipant>();
        List<InsurancePolicyAsset> insurancePolicyAssetList = new List<InsurancePolicyAsset>();
        for(Integer i=0;i<3;i++){     
            participantList.add(new InsurancePolicyParticipant(PrimaryParticipantAccountId=accountList[i].Id,InsurancePolicyId=policyList[i].id,Role='Named Insured') );
            insurancePolicyAssetList.add(new InsurancePolicyAsset(AssetName='1997 Gmc Suburban Sport Wg',RiskStatusText__c='In Force', InsurancePolicyId=policyList[i].id));
        }
        
        insert participantList;
        insert insurancePolicyAssetList;
    }
    private static String generateExternalId(){
        return String.valueOf(system.today().month()) +String.valueOf(system.today().day()) + formatYear();
    }
    private static String formatYear(){
        String str = String.valueOf(system.today().year()); 
        return str.substring(str.length()-2);
    }
}