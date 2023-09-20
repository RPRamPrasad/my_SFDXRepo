@isTest
(seeAllData=false)
public class ActivityMoveControllerTest {
    
    private static final Id MOCK_ACCOUNT_ID = '0012300000FakeAAAA';
    private static final String MOCK_ASSOCIATE_ID = 'ASSOCIATE11';
	private static final String MOCK_ASSOCIATE_ID_OVER_FIELD_CHARACTER_LIMIT = 'ASSOCIATE11';
    private static final String MOCK_CLIENT_ID = 'CLIENTID123';
 	private static final String MOCK_ACTIVITY_ID = '10010';

    @isTest
    private static void testActivityQuery(){
        Test.startTest();
        ActivityMoveController.mockedTempActivityList.add(createActivities(MOCK_CLIENT_ID, MOCK_ACTIVITY_ID, MOCK_ASSOCIATE_ID));
        ActivityMoveController.mockedClientId = MOCK_CLIENT_ID;
        try{
            List<Activities__x> activityList = ActivityMoveController.getActivities(MOCK_ACCOUNT_ID, MOCK_ASSOCIATE_ID);
        	System.assert(activityList.size() == 1, 'activitiy list size was not 1');
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO, 'Exception was thrown');
            boolean exceptionWasThrown = (ex.getMessage() == ActivityMoveController.EXCEPTION_MESSAGE_GET_ACTIVITIES || ex.getMessage() == ActivityMoveController.EXCEPTION_MESSAGE_GET_ACTIVITIES_400_BAD_REQUEST);
            System.assert(exceptionWasThrown, 'An unexpected exception was thrown');
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void testActivityQueryException(){
        Test.startTest();
        ActivityMoveController.mockedTempActivityList = null;
        ActivityMoveController.mockedClientId = MOCK_CLIENT_ID;
        try{
           List<Activities__x> activityList = ActivityMoveController.getActivities(MOCK_ACCOUNT_ID, MOCK_ASSOCIATE_ID);
        }catch(Exception ex){
           System.assertEquals(ActivityMoveController.EXCEPTION_MESSAGE_GET_ACTIVITIES, ex.getMessage(), 'An unexpected exception was thrown');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAgentRoles(){
        Test.startTest();
        List<AgentRole__c> agentRoleList = ActivityMoveController.getAgentRoles(MOCK_ACCOUNT_ID);
	  	System.assert(agentRoleList.size() == 0, 'activities were found'); 
        Test.stopTest();
    } 
    
    @isTest
    private static void testTransferActivities(){
    	Map<String, String> requestIds = new Map<String, String>();
		requestIds.put('fromClientId',MOCK_ACCOUNT_ID);
        requestIds.put('toOwnerAssociateId',MOCK_ASSOCIATE_ID);
        requestIds.put('toClientId',MOCK_ACCOUNT_ID);
        String[] activityIds = new String[] {MOCK_ACTIVITY_ID};
        Test.startTest();
        Map<String, String> response = ActivityMoveController.transferActivitiesToNewAccount(activityIds,requestIds);
       	System.assert(response.size() != 0, 'response should contain data');
        Test.stopTest();
    }
    @isTest
    private static void testGetCurrentUserDetail(){
       Test.startTest();
       User currentUser = ActivityMoveController.getCurrentUserDetail(UserInfo.getUserId());
       System.assert(currentUser.Name == UserInfo.getName(), 'The users name is not equal');
       Test.stopTest();
        
    }
    @isTest
    private static void testGetCurrentUserDetailException(){ 
       Test.startTest();
        try{
            ActivityMoveController.getCurrentUserDetail(MOCK_ACCOUNT_ID);
        }catch(Exception ex){
            System.assertEquals(ActivityMoveController.EXCEPTION_MESSAGE_GET_USER_DETAIL, ex.getMessage(), 'An unexpected exception was thrown');
        }	 
       Test.stopTest();
        
    }
    @isTest
    private static void testGetAccountDetailsException(){ 
       Test.startTest();
        try{
            ActivityMoveController.getAccountDetails(MOCK_ACCOUNT_ID);
        }catch(Exception ex){
            System.assertEquals(ActivityMoveController.EXCEPTION_MESSAGE_GET_ACCOUNT_DETAILS, ex.getMessage(), 'An unexpected exception was thrown');
        }	 
       Test.stopTest();
        
    }

    private static List<String> getActivityIds(){
        List<String> activityIds = new List<String>();
        activityIds.add('1234567');
        activityIds.add('5678900');
        return activityIds;
    } 
    private static Activities__x createActivities(String clientId, String activityId, String associateId){
        Activities__x getActivities = new Activities__x(ActivityID__c = activityId, ClientID__c=clientId, AgentName__c = 'AgentSmith',
                                                        AssociateID__c = associateId, Category__c = 'catID1',
                                                        Customer__c = 'Cust1', Description__c = 'Descriptive', DueDate__c = '2018-12-30',
                                                        Status__c = 'Active', LineOfBusiness__c = 'A', ModifiedDate__c = '2016-06-14 16:56:00.659000000');
        return getActivities;
    }
    
    
    private static String generateRandomString(Integer len){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while(randomString.length() < len){
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(index, index+1);
        }
        return randomString;
    }
}