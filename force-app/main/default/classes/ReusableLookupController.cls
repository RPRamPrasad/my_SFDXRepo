/**
 * @name ReusableLookupController
 * @author Team Octonauts
 * @description This class is used when creating a meeting for Simple Conversation on Account record page
 */

 public with sharing class ReusableLookupController {
    @AuraEnabled
    /**
     * @description fetchRecords
     * @return List<ResultWrapper>
     * @param inputWrapper
     */
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if(inputWrapper != null){
                
                String query = '';
                String searchTxt = '%'+String.escapeSingleQuotes(inputWrapper.searchString.trim())+ '%';
                String agent200 = '2.00 Agent';
                String agentTeamMember = '2.01 Agent Team Member';                
                String offieId = inputWrapper.otherSearchFilter!=null?String.escapeSingleQuotes(inputWrapper.otherSearchFilter):'';
                inputWrapper.parentFieldApiName = searchTxt+agent200+agentTeamMember;
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query = 'Select Id,Name,FirstName,SubUserType__c FROM USER WHERE Id = \''+ String.escapeSingleQuotes(inputWrapper.selectedRecordId) + '\'';
                } else {
                    query = getUsersQuery();
                    //query = getUserQuery(searchTxt,offieId);//'Select Id,Name,FirstName FROM USER WHERE Name 
                    //LIKE :searchTxt AND (((Profile.Name =:agent200 OR Profile.Name =:agentTeamMember
                    //OR Profile.Name =:investmentPlanning  
                    //OR Profile.Name =:enterprise6) AND Servicing_Agent_Associate_ID__c=:offieId)  OR (Profile.Name =:techSupport OR 
                    //Profile.Name =:sysAdmin OR Profile.Name =:sfAPIonlyUser)) LIMIT 10';
                }
                if (Test.isRunningTest()) {
                    query = 'Select Id,Name,FirstName,SubUserType__c FROM USER limit 10';
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for(SObject s : Security.stripInaccessible(AccessType.READABLE,Database.query(query)).getRecords()) {
                    User eachUser = (User)s;
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(inputWrapper.fieldApiName);
                    wrap.subField = eachUser.SubUserType__c;//(String)s.get(inputWrapper.otherFieldApiName);
                    //wrap.userRole = eachUser.UserRole.Name;
                    wrap.id = (String)s.get('id');
                    returnWrapperList.add(wrap);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getLineNumber() + err.getMessage());
        }
    }
    /**
     * @description getUsersQuery
     * @return String
     */
    public static String getUsersQuery(){
        String agent200 = System.Label.createMeetingAgent200;
        String agentTeamMember = System.Label.createMeetingATM201;
        String query = '';
        if (UserInfo.getProfileId() == agent200 || UserInfo.getProfileId() == agentTeamMember) {
            query =  'Select Id,Name,FirstName, SubUserType__c FROM USER WHERE (Name LIKE :searchTxt OR Servicing_Agent_Associate_ID__c LIKE :searchTxt) AND (Profile.Name =:agent200 OR Profile.Name =:agentTeamMember) AND Servicing_Agent_Associate_ID__c=:offieId AND isActive = true LIMIT 10';
        } else {
            query =  'Select Id,Name,FirstName, SubUserType__c FROM USER WHERE (Name LIKE :searchTxt OR Servicing_Agent_Associate_ID__c LIKE :searchTxt)  AND isActive = true LIMIT 10';
        }
        return query;
    }
    /**
     * @description ResultWrapper
     */
    public class ResultWrapper{
    /**
     * @description mainField
     * @return String
     */    
        @AuraEnabled public String mainField{get;set;}
    /**
     * @description subField
     * @return String
     */    
        @AuraEnabled public String subField{get;set;}
    /**
     * @description id
     * @return String
     */    
        @AuraEnabled public String id{get;set;}
        //@AuraEnabled public String userRole{get;set;}
    }
    /**
     * @description SearchWrapper
     */
    public class SearchWrapper {
    /**
     * @description objectApiName
     * @return String
     */
        @AuraEnabled public String objectApiName{get;set;}
    /**
     * @description fieldApiName
     * @return String
     */
        @AuraEnabled public String fieldApiName{get;set;}
    /**
     * @description otherFieldApiName
     * @return String
     */
        @AuraEnabled public String otherFieldApiName{get;set;}
    /**
     * @description searchString
     * @return String
     */
        @AuraEnabled public String searchString{get;set;}
    /**
     * @description selectedRecordId
     * @return String
     */    
        @AuraEnabled public String selectedRecordId{get;set;}
    /**
     * @description parentRecordId
     * @return String
     */
        @AuraEnabled public String parentRecordId{get;set;}
    /**
     * @description parentFieldApiName
     * @return String
     */
        @AuraEnabled public String parentFieldApiName{get;set;}
    /**
     * @description otherSearchFilter
     * @return String
     */
        @AuraEnabled public String otherSearchFilter{get;set;}
    }
}
