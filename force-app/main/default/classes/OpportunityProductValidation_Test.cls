@isTest(SeeAllData=false)
public class OpportunityProductValidation_Test{
    @TestSetup private static void setUpUserData(){
        User agentUser;
        User proxyUser;
        CS001_ByPassTriggerAll__c byPassAllTrigger;
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'oRefAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        System.runAs(adminUser) {
            byPassAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassAllTrigger;

            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Refe',LastName='RefAgnt',Username='RefPrx' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='71ddaa11yycP',Servicing_Agent_Associate_ID__c='71ddaa11yyc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='Ref1',LastName='RefAgn1',Username='RefAgt' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='71ddaa11yyc',UserExternalID__c='71ddaa11yyc_71ddaa11yyc',Servicing_Agent_Associate_ID__c='71ddaa11yyc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.Id);
            insert sysAdminUserIdSetting;
        }
        System.runAs(adminUser) {
            insert new List<OpportunityProduct__c>{
                new OpportunityProduct__c(Lob_Name__c = 'Auto', Product_Postal_State__c = 'IL', Product_Description__c = 'Private Passenger - NECHO', Product_System_Name__c = 'PP_PRSNL_PREF', Product_Start_Date__c = date.newInstance(2015, 01, 01), Product_End_Date__c = date.newInstance(2025, 12, 31),Lob_Cd__c = '111'),
                new OpportunityProduct__c(Lob_Name__c = 'Fire', Product_Postal_State__c = 'IL', Product_Description__c = 'Renters Policy', Product_System_Name__c = 'RENTERS_POLICY', Product_Start_Date__c = date.newInstance(2015, 01, 01), Product_End_Date__c = date.newInstance(2025, 12, 31), Lob_Cd__c = '111'),
                new OpportunityProduct__c(Lob_Name__c = 'Health', Product_Postal_State__c = 'IL', Product_Description__c = 'Supplemental Health', Product_System_Name__c = 'SUPP_HLTH', Product_Start_Date__c = date.newInstance(2015, 12, 01), Product_End_Date__c = date.newInstance(2025, 12, 31), Lob_Cd__c = '111'),
                new OpportunityProduct__c(Lob_Name__c = 'Life', Product_Postal_State__c = 'IL', Product_Description__c = 'Guaranteed Issue Final Expense', Product_System_Name__c = 'GUAR_ISS_FINAL_EXPNS', Product_Start_Date__c = date.newInstance(2015, 01, 01), Product_End_Date__c = date.newInstance(2025, 12, 31), Lob_Cd__c = '111')            
            };
            byPassAllTrigger.Override_All__c = false;
            update byPassAllTrigger;
        }
    }
 
    @isTest private static void testGetOpportunityProducts(){
        User adminUser = [SELECT Id FROM User WHERE Alias  = 'alias' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<OpportunityProduct__c> response =  OpportunityProductValidation.getOpportunityProducts('Auto','IL', date.newInstance(2022, 03, 03)); 
            List<OpportunityProduct__c> response1 =  OpportunityProductValidation.getOpportunityProducts('','IL', date.newInstance(2022, 03, 03)); 
            List<OpportunityProduct__c> response2 =  OpportunityProductValidation.getOpportunityProducts('xxx','IL', date.newInstance(2022, 03, 03)); 
            Test.stopTest();
            System.assertNotEquals(response.size(),0,'No Opportunity Product Available');
            System.assertEquals(null,response1 , 'LOB should not be null');
            System.assertEquals(null,response2 , 'LOB is Not valid');

        }
    }
    
	@isTest private static void testValidateOpportunityProduct(){
        User adminUser = [SELECT Id FROM User WHERE Alias  = 'alias' LIMIT 1];
        System.runAs(adminUser) {
            OpportunityProductValidation.OpportunityDetails oppDetails = new OpportunityProductValidation.OpportunityDetails();
            oppDetails.lob = 'Fire';
            oppDetails.stateCode = 'IL';
            oppDetails.productDescription = 'Renters Policy';
            oppDetails.effectiveDate = date.newInstance(2022, 03, 03);
            oppDetails.productSystemName = 'RENTERS_POLICY';
            Test.startTest();
            OpportunityProduct__c response =  OpportunityProductValidation.validateOpportunityProduct(oppDetails);
            Test.stopTest();
            System.assertEquals(null,response.ErrorFutureDays__c,'Opportunity Product is not valid');

        }
    }
    
    @isTest private static void testValidateOpportunityProductBlankLOB(){
        User adminUser = [SELECT Id FROM User WHERE Alias  = 'alias' LIMIT 1];
        System.runAs(adminUser) {
            OpportunityProductValidation.OpportunityDetails oppDetails = new OpportunityProductValidation.OpportunityDetails();
            oppDetails.lob = '';
            oppDetails.stateCode = 'IL';
            oppDetails.productDescription = '';
            oppDetails.effectiveDate = null;
            oppDetails.productSystemName = 'RENTERS_POLICY';
            Test.startTest();
            OpportunityProduct__c response =  OpportunityProductValidation.validateOpportunityProduct(oppDetails);
            Test.stopTest();
            System.assertEquals(null,response,'Opportunity Product is not valid');

        }
    }

	@isTest private static void testGetProductInformation(){
        User adminUser = [SELECT Id FROM User WHERE Alias  = 'alias' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            OpportunityProductValidation.OpportunityDetails oppDetails = new OpportunityProductValidation.OpportunityDetails();
            oppDetails.lob = 'Auto';
            oppDetails.stateCode = 'IL';
            oppDetails.productDescription = 'Private Passenger - NECHO';
            OpportunityProduct__c response =  OpportunityProductValidation.getProductInformation(oppDetails);
			oppDetails.lob = '';
            oppDetails.productDescription = 'Private Passenger - NECHO';
            OpportunityProduct__c response1 =  OpportunityProductValidation.getProductInformation(oppDetails);
			oppDetails.lob = 'xxx';
            oppDetails.productDescription = 'Private Passenger - NECHO';
            OpportunityProduct__c response2 =  OpportunityProductValidation.getProductInformation(oppDetails);
            Test.stopTest();
            System.assertEquals(null, response.ErrorFutureDays__c, 'No Opportunity Product Available');
            System.assertEquals(null, response1, 'LOB should not be null');
            System.assertEquals(null, response2, 'LOB is Not valid');

        }
    }
    
}