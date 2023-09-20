/**
* Author : Team Kraken (VAASTT)
* @description : Serves as the test class for the BillingTabAgentDataBuilder class
* Date Created : 6/16/21
*/

@isTest
(seeAllData = false)
public with sharing class BillingTabAgentDataBuilder_TEST extends BillingTabModels {


    /**
     * @description Setup Tests by generating agent data and bypassing the appropraite triggers.
     */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

    }



     /**
     * @description setup user for Standard Agent Test
     * @return User
     */
    private static User createStandardAgentData() {

        // Insert User   
        User testAgentUser1 = new User(Alias='Michael',LastName='Palmiotto, NYQZ, 20-94DD',Username='mpalmitto@statefarm.com',Associate_ID__c='123',UserExternalID__c='123_123',Servicing_Agent_Associate_ID__c='123');
        User user = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        user.State_Agent_Code__c = '20-94DD';
        user.Associate_ID__c = '0FKCM2YT000';
        user.FirstName = 'Michael';
        Database.insert(user);

        // We need the Agents Name, so we'll have to pull it from the database manually, Salesforce making things more difficult then they need to be as usual.
        user = [SELECT Name, FirstName, LastName, Associate_ID__c, State_Agent_Code__c FROM User WHERE id=:user.Id]; 

        return user;

    }




    /**
     * @description setup user for Standard Agent Test
     * @return User
     */
    private static User createSFOAgentData() {

        // Insert User  
        User testAgentUser1 = new User(Alias='03-8942',LastName='SFO Phoenix, AZ',Username='mpalmitto@statefarm.com',Associate_ID__c='123',UserExternalID__c='123_123',Servicing_Agent_Associate_ID__c='123'); 
        User user = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        user.State_Agent_Code__c = '03-8942';
        user.FirstName = '03-8942';
        Database.insert(user);

        // We need the Agents Name, so we'll have to pull it from the database manually, Salesforce making things more difficult then they need to be as usual.
        user = [SELECT Name, FirstName, LastName, Associate_ID__c, State_Agent_Code__c FROM User WHERE id=:user.Id]; 

        return user;

    }




    /**
     * @description Test Standard Agents
     */
    @IsTest
    public static void standardAgents() {

        // Data For Test
        User user = createStandardAgentData();

        String expectedStateAgentCode = '20-94DD';
        String expectedServicingAgentName  = 'Michael Palmiotto';
        String expectedServicingAgentUrl = '/c/ExternalLinkApp.app?linkId=26&primaryStateCode=' + expectedStateAgentCode.substring(0,2) +
        '&primaryAgentCode=' + expectedStateAgentCode.substring(3,7);

        AgentData agentDataResult = BillingTabAgentDataBuilder.buildAgentData(user.State_Agent_Code__c, user);

        System.assertEquals(expectedStateAgentCode, agentDataResult.stateAgentCode, 'Invalid State Agent');
        System.assertEquals(expectedStateAgentCode.substring(0,2), agentDataResult.stateCode, 'Invalid State Code');
        System.assertEquals(expectedStateAgentCode.substring(3,7), agentDataResult.agentCode, 'Invalid Agent Code');

        System.assertEquals(expectedServicingAgentName, agentDataResult.servicingAgentName, 'Invalid Servicing Agent Name');
        System.assertEquals(expectedServicingAgentUrl, agentDataResult.servicingAgentUrl, 'Invalud Servicing Agent URL');

    }




    /**
     * @description Test SFO Agents
     */
    @IsTest
    public static void sfoAgents() {

        // Data For Test
        User user = createSFOAgentData();

        String expectedStateAgentCode = '03-8942';
        String expectedServicingAgentName  = 'SFO Phoenix';
        String expectedServicingAgentUrl = '/c/ExternalLinkApp.app?linkId=26&primaryStateCode=' + expectedStateAgentCode.substring(0,2) +
        '&primaryAgentCode=' + expectedStateAgentCode.substring(3,7);

        AgentData agentDataResult = BillingTabAgentDataBuilder.buildAgentData(user.State_Agent_Code__c, user);

        System.assertEquals(expectedStateAgentCode, agentDataResult.stateAgentCode, 'Invalid State Agent');
        System.assertEquals(expectedStateAgentCode.substring(0,2), agentDataResult.stateCode, 'Invalid State Code');
        System.assertEquals(expectedStateAgentCode.substring(3,7), agentDataResult.agentCode, 'Invalid Agent Code');

        System.assertEquals(expectedServicingAgentName, agentDataResult.servicingAgentName, 'Invalid Servicing Agent Name');
        System.assertEquals(expectedServicingAgentUrl, agentDataResult.servicingAgentUrl, 'Invalud Servicing Agent URL');

    }

}
