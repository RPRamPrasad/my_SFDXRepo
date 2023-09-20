/** 
@Author Team Orca
@Name PA_CaseUtilHelper
@CreateDate 09/13/2023
@description This class is used as a helper class to abstract some complexity from PA_CaseUtil
*/
public with sharing class PA_CaseUtilHelper {

    /**
    * @description Method to get AccountData
    * @param accountId
    * @return Account retrieved from SOQL
    */
    @TestVisible
    public static Account getAccountData(Id accountId){
        List<Account> accountList = new List<Account>();
        if(accountId.getSobjectType() == Account.getSObjectType()){
            accountList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, PersonContactId FROM Account WHERE Id = :accountId]).getRecords();
        }
        return accountList.get(0);
    }

    /**
    * @description Method to get policyIdForAuto
    * @param policyNumber
    * @param isLegacyPolicy
    * @return String policyId
    */
    @TestVisible
    public static String getPolicyIdForAuto(String policyNumber, boolean isLegacyPolicy){
        String policyId = policyNumber;
        if(String.isNotBlank(policyId)){
        	if(policyId.containsWhitespace()){
            	policyId = policyId.remove(' ');
        	}
        	if(isLegacyPolicy && policyId.length() >= 7){
                policyId = policyId.substring(0, 7);
            }
        }
        return policyId;
    }
}