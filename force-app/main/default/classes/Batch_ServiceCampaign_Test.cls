@isTest (seeAllData=false)
public with sharing class Batch_ServiceCampaign_Test {
    
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
  
          accountList = new List<Account>();
          for (Integer i=1;i<=3;i++){
              Account account = TestDataFactory_Account.createIndividualCustomer('TestAccName'+i);
              account.ClientIdentifier__c = 'OO11111111'+i;
              accountList.add(account);
          } 
          TestDataFactory_Account.byPassAccountBeforeTrigger();
          TestDataFactory_Account.insertAccount(accountList);
          serviceCampaignList = new List<Service_Campaign__c>();
          Service_Campaign__c serviceCampaign = new Service_Campaign__c(PolicyNumber__c='TESTRISK1',State__c='IL',
                                              CampaignName__c='Removal of Withdrawal from Use January 2023',
                                              CampaignStartDate__c=System.today()+10,ToBeProcessed__c=True);
          serviceCampaignList.add(serviceCampaign);
          insert serviceCampaignList;
          
    }
    
    @isTest       
    private static void testServiceCampaignCreation() {
        Account account;
        List<Service_Campaign__c> service_CampaignList;
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        
        User agentUser = [Select Id,Servicing_Agent_Associate_ID__c from User where UserExternalId__c='OOOO1111111A'];
        account = [SELECT Id, Primary_Household__pc, PersonContactId,ClientIdentifier__c FROM Account WHERE ClientIdentifier__c = 'OO111111111' limit 1];
        TestDataFactory_AgentRole.createAgentRole(agentUser,account,'Customer');

        createPolicyData(agentUser,account);

        System.runAs(sysAdminUser) {
        service_CampaignList = [Select Id,PolicyNumber__c,CampaignName__c,CampaignStartDate__c,ToBeProcessed__c,State__c,AdditionalInformation__c from Service_Campaign__c
                                                        where CampaignName__c='Removal of Withdrawal from Use January 2023'];
        
        Test.startTest();
        Batch_ServiceCampaign batch = new Batch_ServiceCampaign();
		Database.executeBatch(batch);
        Test.stopTest();
        }
        List<Campaign> campaignList = [Select Id,Name,Status,Source__c,StartDate from Campaign Where Name=:service_CampaignList[0].CampaignName__c];
        system.assertEquals(1, campaignList.size(), 'Campaigns not created');
        system.assertEquals(campaignList[0].Status,'Fulfillment Completed','status not completed');
        system.assertEquals(campaignList[0].Source__c,'Report','Source not report');
        system.assertEquals(campaignList[0].StartDate,service_CampaignList[0].CampaignStartDate__c,'StartDate do not match');

        List<CampaignMember> campaignMemberList = [Select Id,ContactId,CampaignId,Status__c,ExternalData__c from CampaignMember where CampaignId=:campaignList[0].id];
        system.assert(campaignMemberList.size()==1,'campaignMemberList size does not match');
        
        for(CampaignMember member: campaignMemberList){
            system.assert(member.ContactId!=null,'contact null');
            system.assert(member.ExternalData__c!=null,'No Policydata');
        }
    }

    private static void createPolicyData (User agent, Account account){
        InsurancePolicy policy = new InsurancePolicy(Servicing_Agent__c=agent.Id,NameInsuredId=account.id,AgreDisplayPartyName__c='TESTNAME',
                                 PolicyType='Auto',PolicyName='Private Passenger', AgreAccessKey__c='TESTRISK1',Name='100 0000-000-22');
        insert policy;

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId=account.Id,InsurancePolicyId=policy.id,Role='Named Insured' );
        insert participant;
        
        InsurancePolicyAsset asset = new InsurancePolicyAsset(AssetName='1997 Gmc Suburban Sport Wg',RiskStatusText__c='In Force', InsurancePolicyId=policy.id);
        insert asset;
    }

}