@isTest
public class TestDataFactory_Case {
   /**
    * @description generateCase
    * @param accountID 
    * @return  `Case`
    */
    public static Case generateCase(String accountID) {
        return generateCases(1, accountID).get(0);
    }
    /**
     * @description generateCases
     * @param numberOfCases 
     * @param accountID 
     * @return  `List<Case>`
     */
    public static List<Case> generateCases(Integer numberOfCases,String accountID) {
        List<Case> caseList = new List<Case>();
        for (Integer x = 0; x < numberOfCases; x++) {
            caseList.add(new Case(Status = 'New', 
                                  Case_Originator__c = 'CCC Sales',                               
                                  AccountId = accountID)
            );
        }
        return caseList;
    }
    /**
     * @description insertCase
     * @param cases 
     * @return  `Case`
     */
    public static Case insertCase(Case cases) {
        List<Case> caseList = new List<Case>();
        caseList.add(cases);
        return insertCases(caseList).get(0);
    }
    /**
     * @description insertCases
     * @param caseList 
     * @return  `List<Case>`
     */
    public static List<Case> insertCases(List<Case> caseList) {
        Id contactId = UTIL_CaseTestData.contactId();
        for(Case newCase : caseList){
            if(newCase.AccountId==null || String.isBlank(newCase.AccountId) 
                || newCase.ContactId == null || String.isBlank(newCase.ContactId)){
                newCase.contactId = contactId;
            }
        }
        insert caseList;        
        return caseList;
    }
    /**
     * @description createCaseShareForProxy
     * @param caseRecord 
     * @param proxyUser 
     */
    public static void createCaseShareForProxy(Case caseRecord, User proxyUser){
        CaseShare caseshare = new CaseShare(CaseId= caseRecord.Id, UserOrGroupId= proxyUser.Id, CaseAccessLevel='Edit', RowCause= 'Manual');
        insert caseshare;
    }
    /**
     * @description byPassCaseBeforeTrigger
     */
    public static void byPassCaseBeforeTrigger() {
        CS001_ByPassTriggerAtoF__c byPassUserTrigger = CS001_ByPassTriggerAtoF__c.getInstance(UserInfo.getUserId());
        if (byPassUserTrigger.Override_CaseBeforeInsert__c == false) {
            byPassUserTrigger.Override_CaseBeforeInsert__c = true;
            upsert byPassUserTrigger;
        }
    }
}