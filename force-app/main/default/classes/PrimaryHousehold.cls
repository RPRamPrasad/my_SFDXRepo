/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

/**
* Author : Team Stark | Targaryen
* Date Created : 06/30/2020
* @description : The class is responsible to provide Household Id to a lightning component to open on Household Page.
* Modification Log -  Added Caching Account Id for CCC Users on 11/01/2021
*/

/**
* Author : Team Stark | Targaryen
* Date Created : 08/08/2022
* @description : The class is responsible to provide Household Id to a lightning component to open on Household Page.
* Modification Log -  Let Agency Users Land on Account Page and Land on HH Page after completion of HH Transaction
*/
public with sharing class PrimaryHousehold {
    /**
    * @description 
    * @author Stark / Targaryen.SFDoc | 05-15-2020
    * @param acctId 
    * @return Account 
    **/

    
    private static final Integer HOLDTIME_TO_LAND_ON_HH_AFTER_HH_TRANSACTION = 90;
   
    @TestVisible private static boolean actionFromManageHousehold = false;
    
    private static final String USER_TYPE_AGENCY = 'Agency';
    
    @TestVisible private static Datetime currentSystemTime;
    @TestVisible private static Datetime mostRecentHHUpdate;

    @AuraEnabled
    public static Account findPrimaryHousehold(String acctId) { 
        List<Account> accounts;
        List<Account> hhAccounts;
        Cache.SessionPartition sessionPart;

        List<User> loggedInUser = Security.stripInaccessible(AccessType.READABLE,[SELECT UserType__c, SubUserType__c 
                                                                            FROM User 
                                                                            WHERE Id =:UserInfo.getUserId() LIMIT 1
                                                                            ]).getRecords();
        String loggedInUserInfoType = loggedInUser.get(0).UserType__c;

            try{
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', acctId, Account.class);
                accounts = Security.stripInaccessible(AccessType.READABLE, 
                                                        [
                                                            SELECT Id, Primary_Household__pc, LastModifiedDate from Account 
                                                            WHERE id = :String.escapeSingleQuotes(acctId) LIMIT 1
                                                        ]
                                                        ).getRecords();
                
                sessionPart = Cache.Session.getPartition('local.Household');

                if(accounts.get(0).Primary_Household__pc <> NULL){
                
                    sessionPart.put(accounts.get(0).Primary_Household__pc, acctId);

                    hhAccounts = Security.stripInaccessible(AccessType.READABLE, 
                                                            [
                                                                SELECT Id, Name, LastModifiedDate from Account 
                                                                WHERE Id = :accounts.get(0).Primary_Household__pc LIMIT 1
                                                            ]
                                                            ).getRecords();
                 }
            }catch (Exception exp) {
                LoggingService.logHandledException(exp, 'PrimaryHousehold','findPrimaryHousehold', System.LoggingLevel.ERROR);
            }

                
        if(USER_TYPE_AGENCY.equals(loggedInUserInfoType) && accounts.get(0).Primary_Household__pc <> NULL){
            currentSystemTime = System.now();
            mostRecentHHUpdate = hhAccounts.get(0).LastModifiedDate.addSeconds(HOLDTIME_TO_LAND_ON_HH_AFTER_HH_TRANSACTION);

            if(currentSystemTime < mostRecentHHUpdate){
                actionFromManageHousehold = true;
            }
        }

        return decideLandsOnAccountOrHousehold(loggedInUserInfoType,accounts);
          
    }  

    private static Account decideLandsOnAccountOrHousehold(String loggedInUserInfoType, List<Account> accounts){
        if(USER_TYPE_AGENCY.equals(loggedInUserInfoType) && actionFromManageHousehold){
            return accounts[0];
        } else{
            return null; 
        }

    }
   
}