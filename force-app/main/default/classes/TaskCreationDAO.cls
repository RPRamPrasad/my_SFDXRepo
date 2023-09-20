/**
 * @name TaskCreationDAO
 * @description handles the creation of tasks from templates
*/
public with sharing class TaskCreationDAO {

    /**
     * @name getCustomTemplatesByTemplateType
     * @description uses the passed in Template Type to query for applicable task information to create tasks
     * @param templateType
     * @return List<Custom_Template__c>
     */
    public static List<Custom_Template__c> getCustomTemplatesByTemplateType(String templateType){
        UTIL_ParameterValidator validator = UTIL_ParameterValidationFactory.getParameterValidator(ParameterType.ALL_PARAMETER);
        validator.validateParameter('templateType', templateType);

        List<Custom_Template__c> customTemplates = [SELECT Id, Task_Category__c, Due_Date_Number_of_Days_from_Today__c
        , Task_Due_Date__c, Task_Description__c, Task_SubCategory__c, Task_Priority__c
        , Task_Subject__c, Task_Type__c, Template_Type__c, Custom_Template_Title__c,Template_Sub_Type__c, Name FROM Custom_Template__c
        WHERE Template_Type__c = :templateType WITH SECURITY_ENFORCED ORDER BY Due_Date_Number_of_Days_from_Today__c ASC LIMIT 100];
           
        return Security.stripInaccessible(AccessType.READABLE, customTemplates).getRecords();
    }
}