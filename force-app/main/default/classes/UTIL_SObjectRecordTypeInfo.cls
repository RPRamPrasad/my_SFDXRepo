/**
 * @description UTIL_SObjectRecordTypeInfo
 */
public with sharing class UTIL_SObjectRecordTypeInfo {

    //Task Object
    public static final Id TASK_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Master').getRecordTypeId();
    public static final Id TASK_TASK_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
    public static final Id TASK_LOG_CALL_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Log_Call').getRecordTypeId();

}