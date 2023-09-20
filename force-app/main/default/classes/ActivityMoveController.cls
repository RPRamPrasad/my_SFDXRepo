/**
* @author GrumpyCats
* @name ActivityMoveController
* @date Created 02/20/2020
* @description ActivityMoveUI controller class. This class will call out to get ABS activities, transfer activities to different account 
*/
public with sharing class ActivityMoveController {

    @TestVisible private static final String EXCEPTION_MESSAGE_GET_ACTIVITIES = 'There was a failure during the retrieval of Activities. If the issues persists contact technical support.';
    @TestVisible private static final String EXCEPTION_MESSAGE_GET_ACTIVITIES_400_BAD_REQUEST = 'A bad request was sent the values used were: ';
    @TestVisible private static final String EXCEPTION_MESSAGE_GET_USER_DETAIL = 'There was an error getting the current users details. If the issues persists contact technical support.';
    @TestVisible private static final String EXCEPTION_MESSAGE_GET_ACCOUNT_DETAILS = 'There was an error getting the current account details. If the issues persists contact technical support.';
    @TestVisible private static List<Activities__x> mockedTempActivityList = new List<Activities__x>();     
	@TestVisible private static String mockedClientId = '';

    @AuraEnabled
    public static Map<String, String>transferActivitiesToNewAccount(String[] activityIds, Map<String, String> requestIds){ 
        return ABS_ActivityManagementCallout.callActivityMoveService(buildActivityMoveRequestBody(activityIds, requestIds));
    }
    
    @AuraEnabled
    public static List<Activities__x> getActivities(Id accountId, String agentAssociateId){
        
        String clientIdentifier = setClientId(accountId); 
        String currentUserAlias = getCurrentUserDetail(UserInfo.getUserId()).Alias;
        
        List<Activities__x> oDataCallActivityList = new List<Activities__x>();
 
        List<Activities__x> oDataCallArchivedActivityList = new List<Activities__x>();
        
        oDataCallArchivedActivityList =  Security.stripInaccessible(AccessType.READABLE, [SELECT ActivityID__c, Description__c, Customer__c, UserID__c,  
                                 ClientID__c, LineOfBusiness__c, AssociateId__c, AgentName__c, DueDate__c, ModifiedDate__c, Category__c     
                                 FROM Activities__x 
                                 WHERE ClientID__c =: clientIdentifier
                                 AND AssociateId__c =:agentAssociateId
                                 AND UserID__c =: currentUserAlias
                                 AND StatusFilter__c = 'Archived']).getRecords();
          
        oDataCallActivityList.addall(oDataCallArchivedActivityList);

        if(Test.isRunningTest()){
            oDataCallActivityList = mockedTempActivityList;
        }
        
        return  oDataCallActivityList;
    }
    
    @AuraEnabled
    public static List<AgentRole__c> getAgentRoles(Id accountId){
        List<AgentRole__c> agentRoleList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Agent__c, Agent__r.Name, Agent__r.Servicing_Agent_Associate_Id__c, Agent__r.Associate_ID__c FROM AgentRole__c WHERE Customer__c =: accountId]).getRecords();
        return agentRoleList;
    }
    
	@TestVisible
    private static User getCurrentUserDetail(String userId){
        try{
            List<User> userList = Security.stripInaccessible(AccessType.READABLE, [SELECT Name, Alias FROM User WHERE Id =: userId LIMIT 1]).getRecords();
        	return userList.get(0);
        }catch(Exception ex){
            ex.setMessage(EXCEPTION_MESSAGE_GET_USER_DETAIL);
            throw ex;
        }
    }
    
    @TestVisible
     private static Account getAccountDetails(Id accountId){
        try{
            List<Account> accountList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE Id =: accountId LIMIT 1]).getRecords();
            return accountList.get(0);
        }catch(Exception ex){
            ex.setMessage(EXCEPTION_MESSAGE_GET_ACCOUNT_DETAILS);
            throw ex;
        }
    }
	
    @TestVisible
    private static String setClientId(Id accountId){
        String clientIdentifier = '';
        if(Test.isRunningTest()){
        	clientIdentifier = mockedClientId;    
        }else{
            Account account = getAccountDetails(accountId);
            clientIdentifier = account.ClientIdentifier__c;
        }
        return clientIdentifier;
    }
    
    private static String buildActivityMoveRequestBody(String[] activityIds, Map<String, String> requestIds){
        String requestBody;
        String modifierAlias = UTIL_CurrentUser.retrieveCurrentUser().Alias;
        
        XmlStreamWriter xmlWriter = new XmlStreamWriter();
        xmlWriter.writeStartDocument(null, '1.0');
        
        xmlWriter.writeStartElement(null, 'MoveClient', null);
        
        xmlWriter.writeStartElement(null, 'status', null);	
        xmlWriter.writeCharacters('00005');
        xmlWriter.writeEndElement(); //end status	
        
        xmlWriter.writeStartElement(null, 'activityIds', null);
            for(String activityId:activityIds){
                xmlWriter.writeStartElement(null, 'activityId', null);
                xmlWriter.writeCharacters(activityId);
                xmlWriter.writeEndElement(); //end activityId 
            }
        xmlWriter.writeEndElement(); //end activityIds 	
        
        xmlWriter.writeStartElement(null, 'fromClientId', null);	
        xmlWriter.writeCharacters(requestIds.get('fromClientId'));
        xmlWriter.writeEndElement(); //end fromClientId 	
        
        xmlWriter.writeStartElement(null, 'toClientId', null);	
        xmlWriter.writeCharacters(requestIds.get('toClientId'));
        xmlWriter.writeEndElement(); //end toClientId 	
        
        xmlWriter.writeStartElement(null, 'toOwnerAssociateId', null);	
        xmlWriter.writeCharacters(requestIds.get('toOwnerAssociateId'));
        xmlWriter.writeEndElement(); //end toOwnerAssociateId 	
        
        xmlWriter.writeStartElement(null, 'modifierAlias', null);	
        xmlWriter.writeCharacters(modifierAlias);
        xmlWriter.writeEndElement(); //end modifierAlias 	
        
        xmlWriter.writeEndElement(); //end MoveClient
        xmlWriter.writeEndDocument();
        requestBody = xmlWriter.getXmlString();
        xmlWriter.close();
        
        return requestBody;
    }
}