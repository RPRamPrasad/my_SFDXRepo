/**
Decription: this class is responsible for taking in an account object and handling database CRUD operations.
Team: ImpactForce & Team Pike
Owner: Stark
Date: 8/30/2016
*/

/**
 * @description HLPR_AccountDAO
 */
public with sharing class HLPR_AccountDAO {
    private static final String CLASS_NAME = 'HLPR_AccountDAO';
    
/**
* Method Name: upsertAccount
* @description upsertAccount
* @param account - a Account object
* @throws expection - Throws a DMLException or another runtime exception which needs to be handled by calling class. This class will log the DMLExpections
*/
    public void upsertAccount(Account account) {
        if(account != null) {
            upsert account ClientIdentifier__c;
        } 
    }
    
/**
* Method Name: insertAccount
* @description insertAccount
* @param account - a Account object
* @throws expection - Throws a DMLException or another runtime exception which needs to be handled by calling class. This class will log the DMLExpections
*/ 

    public void insertAccount(Account account){
        if(account != null) {
            insert account; 
        }
    }
    
/**
* Method Name: updateAccount
* @description updateAccount
* @param account - a Account object
* @throws expection - Throws a DMLException or another runtime exception which needs to be handled by calling class. This class will log the DMLExpections
*/ 

    public void updateAccount(Account account){
        if(account != null) {
            //Get Account Id using ClientIdentifier__c.
            List<Account> accountList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id FROM Account WHERE ClientIdentifier__c = :account.ClientIdentifier__c LIMIT 1]).getRecords();
            //Update Account Id.
            if(accountList != null && !accountList.isEmpty()) {
                account.Id = accountList.get(0).Id;
                update account;
            }
        }                 
    }
    
}