/**  
@Author Loco Motivated/Impact Force  
@name UTIL_AccountMessageDAO
@CreateDate 10/04/2016 
@description This is a utility class that implements Inserting AcoountMessages
@Version 2.0
*/
public without sharing class UTIL_AccountMessageDAO {
    
    /**
* @method insertAccountMessages: Insert Account Messages
* @description Insert Account Messages
* @param listAccountMessagesToInsert
* @throws DMLException 
*/    
    public static void insertAccountMessages(List<AccountMessage__c> listAccountMessagesToInsert){
        
        if(listAccountMessagesToInsert!= null && !listAccountMessagesToInsert.isEmpty()){
            
            insert listAccountMessagesToInsert;
        }
    }
    
    /**
    * @method updateAccountMessages: update Account Messages
    * @description Update Account Messages
    * @param accountMessageList
    * @throws DMLException 
    */    
    public static void updateAccountMessages(List<AccountMessage__c> accountMessageList){
        
        if(accountMessageList!= null && !accountMessageList.isEmpty()){
            
            update accountMessageList;
        }
    }
    
    /**
    * @description upsertAccountMessages: upsert Account Messages
    * @param accountMessageList
    * @throws DMLException 
    */    
    public static void upsertAccountMessages(List<AccountMessage__c> accountMessageList){
        
        if(accountMessageList!= null && !accountMessageList.isEmpty()){
            
            upsert accountMessageList;
        }
    }
    
        /**
    * @description deleteAccountMessages: delete Account Messages
    * @param accountMessageList
    * @throws DMLException 
    */    
    public static void deleteAccountMessages(List<AccountMessage__c> accountMessageList){
        
        if(accountMessageList!= null && !accountMessageList.isEmpty()){
            
            delete accountMessageList;
        }
    }
    
}