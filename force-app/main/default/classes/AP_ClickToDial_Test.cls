@istest(SeeAllData=False)
public class AP_ClickToDial_Test {
    private static String admin_User = 'rolloutTestSystemAdminUser@statefarm.com';
    private static String click_To_Dial = 'ClickToDial';
    public static Map<String, Id> callCenterIdMap;
    
    /**
    * @description Setup method used for building test data 
    */ 
    @testSetup
    public static void testsetupData(){
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile(Admin_User);   
        insert sysAdminUser;
    }

    private static  Click_to_Dial__c buildClickToDial(){
         return new Click_to_Dial__c (Name__c='Test',Agent_Associate_ID__c= 'Test123');  
    }
    
    /**
    * @description Method to test fetch call center Id
    * @param  callCenterName
    * @return callCenterId
    */
    public static Id callCenterId(string callCenterName) {        
        return [select Id from Callcenter where name=: callCenterName LIMIT 1].Id;        
    }
    
    /**
    * @description Method to test Insert Agent user and Add click to dial agent
    */
    @isTest
    public static void testAddClickToDialAgent(){        
        User sysAdminUser = [select id from User where username =:Admin_User];
        User testAgentUser = new User(Alias='ALIAS',LastName='LASTNAME',Username='username@statefarm.com',Associate_ID__c='Test123',UserExternalID__c='ASSOCIATEID',Servicing_Agent_Associate_ID__c='ASSOCIATEID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='Test123',Territory_Associate_ID_List__c='TERRITORYID');        
        user agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUser;
        
        system.runAs(sysAdminUser){            
            Click_to_Dial__c clickToDial = buildClickToDial();
            Database.SaveResult result= Database.insert(clickToDial);
            system.assert(result.isSuccess(), 'Agent User does not exist');
            user addClickToDialAgent=[select id,ClickToDialEnabled__c,CallCenterID from User where id=:agentUser.id];
            
            system.assertEquals(callCenterId(AP_UserProvisioningConstants.CCLA), addClickToDialAgent.CallCenterId, 'Add Click to Dial Agent Call Center Id');
            system.assertEquals(false, addClickToDialAgent.ClickToDialEnabled__c, 'Add click to dial agent Checkbox is false to Dial Agent');            
        }
    }
 
    /**
    * @description Method to test Insert Agent user and delete click to dial agent
    */
    @isTest
    public static void testDeleteClickToDialAgent(){        
        User sysAdminUser = [select id from User where username =:Admin_User];
        User testAgentUser = new User(Alias='ALIAS',LastName='LASTNAME',Username='username@statefarm.com',Associate_ID__c='Test123',UserExternalID__c='ASSOCIATEID',Servicing_Agent_Associate_ID__c='ASSOCIATEID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='Test123',Territory_Associate_ID_List__c='TERRITORYID');
        user agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUser;
        
        system.runAs(sysAdminUser){            
            Click_to_Dial__c clickToDial = buildClickToDial();
            Database.SaveResult result= Database.insert(clickToDial);
            system.assert(result.isSuccess(), 'Agent User does not exist');
            Database.Delete(clickToDial);
            user deleteClickToDialAgent=[select id,ClickToDialEnabled__c,CallCenterID from User where id =:agentUser.id];
            
            system.assertEquals(callCenterId(AP_UserProvisioningConstants.NONCCLA), deleteClickToDialAgent.CallCenterId, 'Error Response');
            system.assertEquals(true, deleteClickToDialAgent.ClickToDialEnabled__c, 'Click to Dial Checkbox is true to dial agent');
        }
    }

    /**
    * @description Method to test Insert list of ATM users 
    */
    @isTest
    public static void testAddClickToDialATM(){
        List<user>aTMUsers = New list<user>();
        User sysAdminUser = [select id from User where username =:Admin_User];
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='uuuussssernewname@statefarm.com',Associate_ID__c='Test123',UserExternalID__c='Test123',Servicing_Agent_Associate_ID__c='Test123',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test123',Territory_Associate_ID_List__c='TERRASSOCID');
        user agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUser;
        testAgentUser = new User(Alias='ALIAS2',LastName='LASTNAME2',Username='uuuussssernewname2@statefarm.com',Associate_ID__c='Test222',UserExternalID__c='Test222',Servicing_Agent_Associate_ID__c='Test222',Territory_Associate_ID__c='TERRASSOID2',Servicing_Agent_Associate_ID_List__c='Test222,Test111',Territory_Associate_ID_List__c='TERRASSOID2,TERRASSOID1'); 
        user agentUserTwo = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUserTwo;
        User testATMUser = new User(Alias='TEST1',LastName='LastNAME1',Username='atmNewUsernameOne@statefarm.com',Associate_ID__c='ATM1',UserExternalID__c='ATM1_Test123',Servicing_Agent_Associate_ID__c='Test123',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test123',Territory_Associate_ID_List__c='TERRASSOCID');
        user aTmUserOne=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        testATMUser = new User(Alias='TEST2',LastName='LastNAME2',Username='atmNewUsernameTwo@statefarm.com',Associate_ID__c='ATM2',UserExternalID__c='ATM2_Test123',Servicing_Agent_Associate_ID__c='Test123',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test123',Territory_Associate_ID_List__c='TERRASSOCID');
        user aTmUserTWO=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        testATMUser = new User(Alias='TEST3',LastName='LastNAME3',Username='atmNewUsernameTHREE@statefarm.com',Associate_ID__c='ATM3',UserExternalID__c='ATM3_Test123',Servicing_Agent_Associate_ID__c='Test123',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test123,Test222',Territory_Associate_ID_List__c='TERRASSOCID,TERRASSOCID');
        user aTmUserTHREE=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        testATMUser = new User(Alias='TEST3',LastName='LastNAME3',Username='atmNewUsernameTHREE_2@statefarm.com',Associate_ID__c='ATM3',UserExternalID__c='ATM3_Test222',Servicing_Agent_Associate_ID__c='Test222',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test123,Test222',Territory_Associate_ID_List__c='TERRASSOCID,TERRASSOCID');
        user aTmUserTHREE_2=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        testATMUser = new User(Alias='TEST4',LastName='LastNAME4',Username='atmNewUsernameFOUR@statefarm.com',Associate_ID__c='ATM4',UserExternalID__c='ATM4_Test222',Servicing_Agent_Associate_ID__c='Test222',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test222,Test123',Territory_Associate_ID_List__c='TERRASSOCID,TERRASSOCID');
        user aTmUserFOUR=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        testATMUser = new User(Alias='TEST4',LastName='LastNAME4',Username='atmNewUsernameFOUR_2@statefarm.com',Associate_ID__c='ATM4',UserExternalID__c='ATM4_Test123',Servicing_Agent_Associate_ID__c='Test123',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='Test222,Test123',Territory_Associate_ID_List__c='TERRASSOCID,TERRASSOCID');
        user aTmUserFOUR_2=UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        aTmUsers.add(aTmUserOne);
        aTmUsers.add(aTmUserTwo);
        aTmUsers.add(aTmUserThree);
        aTmUsers.add(aTmUserThree_2);
        aTmUsers.add(aTmUserFOUR);
        aTmUsers.add(aTmUserFOUR_2);
        insert aTMUsers;
        system.runAs(sysAdminUser){   
            Click_to_Dial__c clickToDial = buildClickToDial();
            Database.SaveResult result= Database.insert(clickToDial);
            system.assert(result.isSuccess(), 'Agent User does not exist');
        }
        List<user>insertedATMUsers=[select id,ClickToDialEnabled__c,CallCenterID from User where id IN:aTMUsers and servicing_agent_associate_id__c = 'Test123'];
        
        for(user insertedATM:insertedATMUsers){
            system.assertEquals(callCenterId(AP_UserProvisioningConstants.CCLA), insertedATM.CallCenterId, 'Inserted ATM Call Center Id');
            system.assertEquals(false, insertedATM.ClickToDialEnabled__c, 'Click to Dial Checkbox is false to list of ATM users');
        }     
    }
  
    /**
    * @description Method to test Disaply Error When Agent does not exist
    */
    @isTest
    public static void testErrorWhenAgentDoesnotExist(){
        User sysAdminUser = [select id from User where username =:Admin_User];
        
        system.runAs(sysAdminUser){
            Click_to_Dial__c clickToDial = buildClickToDial();
            Database.SaveResult result= Database.insert(clickToDial,false);
            system.assertEquals(false, result.isSuccess(), 'Agent User does not exist');
            system.assertEquals('Associate ID provided does not match with any Agent\'s Associate ID', result.getErrors().get(0).getMessage(), 'Error Response'); 
        }    
    }
 
    /**
    * @description Method to test Disaply Error When Agent Exist
    */
    @isTest
    public static void testErrorWhenAgentExist(){        
        User sysAdminUser = [select id from User where username =:Admin_User];   
        User testATMUser = new User(Alias='ALIAS',LastName='LASTNAME',Username='uuuussssernewname@statefarm.com',Associate_ID__c='Test123',UserExternalID__c='ASSOCIATEID',Servicing_Agent_Associate_ID__c='ASSOCIATEID',Territory_Associate_ID__c='TERRASSOCID',Servicing_Agent_Associate_ID_List__c='ASSOCIATEID',Territory_Associate_ID_List__c='TERRASSOCID');    
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testATMUser);
        insert agentUser;
        system.runAs(sysAdminUser){
            Click_to_Dial__c clickToDial = buildClickToDial();            
            Database.SaveResult result= Database.insert(clickToDial,false);
            system.assertEquals(true, result.isSuccess(), 'Agent User exist');
        }    
    }

    /**
    * @description Method to test Add Click to Dial Shared Agent
    */
    @isTest
    public static void testAddClickToDialSharedAgent(){      
        User sysAdminUser = [select id from User where username =:Admin_User];
        User testAgentUser = new User(Alias='ALIAS1',LastName='LASTNAME1',Username='uuuussssernewname1@statefarm.com',Associate_ID__c='Test111',UserExternalID__c='Test111',Servicing_Agent_Associate_ID__c='Test111',Territory_Associate_ID__c='TERRASSOID1',Servicing_Agent_Associate_ID_List__c='Test111,Test222',Territory_Associate_ID_List__c='TERRASSOID1,TERRASSOID2');
        user agentUserOne = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUserOne;
        testAgentUser = new User(Alias='ALIAS2',LastName='LASTNAME2',Username='uuuussssernewname2@statefarm.com',Associate_ID__c='Test222',UserExternalID__c='Test222',Servicing_Agent_Associate_ID__c='Test222',Territory_Associate_ID__c='TERRASSOID2',Servicing_Agent_Associate_ID_List__c='Test222,Test111',Territory_Associate_ID_List__c='TERRASSOID2,TERRASSOID1');
        user agentUserTwo = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        insert agentUserTwo; 
        User testATMUser = new User(Alias='ATM33',LastName='ATM',Username='333TestATM@statefarm.com',Associate_ID__c='333TestATM',UserExternalID__c='333TestATM',Servicing_Agent_Associate_ID__c='Test111',Territory_Associate_ID__c='TERRASSOID1',Servicing_Agent_Associate_ID_List__c='Test111'+System.Label.CL_LIST_DELIMITER+'Test222',Territory_Associate_ID_List__c='TERRASSOID1'+System.Label.CL_LIST_DELIMITER+'TERRASSOID1');       
        User atmUser = UTIL_UserProvisioning_TEST.buildATMUser(testATMUser);
        insert aTMUser;
        system.runAs(sysAdminUser){            
            Click_to_Dial__c clickToDial1 = new Click_to_Dial__c (Name__c='TestOne',Agent_Associate_ID__c= 'Test111');
            Database.SaveResult result1 = Database.insert(clickToDial1); 
            system.assert(result1.isSuccess(), 'Agent User does not exist');
            
            Click_to_Dial__c clickToDial2 = new Click_to_Dial__c (Name__c='TestTwo',Agent_Associate_ID__c= 'Test222');
            Database.SaveResult result2 = Database.insert(clickToDial2);  
            system.assert(result2.isSuccess(), 'Agent User does not exist');
            //Delete One Shared Agent from Click to Dial object
            Database.Delete(clickToDial2);      
        }
        User insertedATMUser = [select id,ClickToDialEnabled__c,CallCenterID from User where id =:aTMUser.Id];
        system.assertEquals(callCenterId(AP_UserProvisioningConstants.CCLA), insertedATMUser.CallCenterId, 'Inserted ATM User Id');
        system.assertEquals(false, insertedATMUser.ClickToDialEnabled__c, 'Click to Dial is false');
    }  

}