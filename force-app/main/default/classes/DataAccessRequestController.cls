/** 
* @description contoller used for Data Access Request Aura action on Account Page 
* @Owner: Grumpycats
*/
public with sharing class DataAccessRequestController {
	/**
     * @description createDataAccessRequest
     * @param accountObject 
     * @return  `String`
     */
    @AuraEnabled
    public static String createDataAccessRequest(Account accountObject){
        List<Case> caseList = new List<Case>();
        CaseFactoryDataAccessRequest caseFactory = new CaseFactoryDataAccessRequest();
        Case darCase = caseFactory.buildCase(accountObject);
        caseList.add(darCase);
        caseList = Security.stripInaccessible(AccessType.CREATABLE, caseList, true).getRecords();
        insert caseList;
        return caseList.get(0).Id;
    }
}