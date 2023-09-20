/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 10/11/2022
* @description : Test class for the HA4C_PKCE class
*/
@isTest(seeAllData=false)
public class HA4C_PKCE_Test {
    @isTest
    private static void testGetVFOriginReturnsCorrectValue() {
        String expectedString = 'https://' + DomainCreator.getVisualforceHostname('c');
        System.assertEquals(HA4C_PKCE.getVFOrigin(), expectedString,'Origin URL not Euqal');
    }

    @isTest
    private static void testGetHA4CTokenReturnsNullFirst() {
        System.assertEquals(HA4C_PKCE.getHA4CToken(), null,'Session token value is not valid');
    }

    @isTest
    private static void testGetHA4CTokenReturnsCorrectValue() {
        Test.StartTest();
        Cache.Session.put('local.HA4CToken.token', 'test');
        String cacheVal = (String) HA4C_PKCE.getHA4CToken();
        Cache.Session.remove('local.HA4CToken.token');
        Test.StopTest();
        System.assertEquals(cacheVal, 'test','Session token value is not valid');
    }

    @isTest
    private static void testGettingOrigin() {
        HA4C_PKCE myHA4CPKCE = new HA4C_PKCE();
        String expectedString = 'https://' + DomainCreator.getLightningHostname();
        System.assertEquals(myHA4CPKCE.origin, expectedString,'Origin URL not Euqal');
    }

    @isTest
    private static void testGettingToken() {
        Test.StartTest();
        HA4C_PKCE myHA4CPKCE = new HA4C_PKCE();
        myHA4CPKCE.token = 'abc';
        myHA4CPKCE.setToken();
        String cacheVal = (String) Cache.Session.get('local.HA4CToken.token');
        Cache.Session.remove('local.HA4CToken.token');
        Test.StopTest();
        System.assertEquals(cacheVal, 'abc','Expected value is '+cacheVal+', but actual value is abc');
    }

    @isTest
    public static void testIsHatsorHA4CCuserORCustomPermTrue(){
      	Profile agentProfile = [Select Id from Profile where name = :UTIL_Constants.AGENT_PROFILE_NAME LIMIT 1];
        User agent1 = new User(
        	firstname='Joe',
            lastname='Smith, ABCD, 01-1234',
            associate_id__c='ABC12345678',
            state_agent_code__c='01-1234',
            alias = 'ABCD', 
            email= 'testuser@statefarm.com', 
            profileid = agentProfile.id,
            emailencodingkey='UTF-8', 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            timezonesidkey='Europe/London', 
            username= 'smith@statefarm.com',
            SubUserType__c='Agent',
            Servicing_Agent_Associate_ID__c='ABC12345678',
            Pilot_User_2__c = 'HATSUser',
			Pilot_User_1__c = 'Ha4cUser'
        );
        insert agent1;
        Test.startTest();
        System.runAs(agent1){
            Boolean checkHatsUserORCustomPerm = HA4C_PKCE.isHatsUser(agent1);
            Boolean checkHa4cUserORCustomPerm = HA4C_PKCE.isHa4cUser(agent1);
			Boolean checkHATSorHA4CuserORcustomPermission =  HA4C_PKCE.isHatsORha4cUser(); 
            System.assertEquals(true, checkHatsUserORCustomPerm, 'Hats user see Necho launch From Case');
 			System.assertEquals(true, checkHa4cUserORCustomPerm, 'Ha4c user see Necho launch From Case');
			System.assertEquals(true, checkHATSorHA4CuserORcustomPermission, 'Hats or HA4C user see Necho launch From Case');
        }
      	Test.stopTest();
    }
}
