/**************************
     * Scenerio: SysAdmin Creates/deploys Custom Object Opportunity_Note__c on Salesforce
     * 
     * Given an Salesforce environment
     * When SysAdmin Creates Custom Object Opportunity_Note__c
     * Then Object created and permissions set appropriately for profiles
     * 
     * Related Stories: 
     * S-178259, S-178260, S-200865
     * 
     * ***********************/
    /** 
     * @description BDD_Config_Sobject_OpportunityNotes_TEST
    */
@isTest
private class BDD_Config_Sobject_OpportunityNotes_TEST {

    private static BDD_CONFIG_Sobject_StepDefinition sobjectStepDefinition = null;
    
    @isTest
    static void verifyOpportunityNotesConfigObject() {
		sobjectStepDefinition = new BDD_CONFIG_Sobject_StepDefinition();
		sobjectStepDefinition.givenAdminUser();
		sobjectStepDefinition.whenDeploysSObject('Opportunity_Note__c');
		thenVerifyObjectMetadata();
		thenVerifyObjectPermissions();
		thenVerifyObjectFieldsMetadata();
		thenVerifyFieldPermissions();
    }
    
    private static void thenVerifyObjectMetadata() {
        sobjectStepDefinition.thenVerifySobjectLabel('Opportunity Note');
		sobjectStepDefinition.thenVerifySobjectApiName('Opportunity_Note__c');
    }
    
   /**
    * Parmeters for thenVerifySobjectHasField:
    * 1: Field Label
    * 2: Field API Name
    * 3: isNillable Field
    * 4: Field Type
    * 5: Field Length
    * @description thenVerifyObjectFieldsMetadata
    */ 
    private static void thenVerifyObjectFieldsMetadata() {
    	sobjectStepDefinition.thenVerifySobjectHasField('Subject', 'Name',false, DisplayType.String, 80);
        sobjectStepDefinition.thenVerifySobjectHasField('Comments', 'Comments__c', false, DisplayType.TextArea, 10000);
        Map<String, String> fieldMap = new Map<String, String>();	
        fieldMap.put('fieldLabel','Opportunity');
        fieldMap.put('fieldName','Opportunity__c');
        fieldMap.put('relationshipName','Opportunity__r');
        fieldMap.put('referenceTo','Opportunity');
        sobjectStepDefinition.thenVerifySObjectHasRelationship(fieldMap,false, DisplayType.Reference);
    }
    
    /**
    * Parmeters for thenVerifySobjectPermissions:
    * 1: Profile or Permission Set Name
    * 2: Read Permission
    * 3: Create Permission
    * 4: Edit Permission
    * 5: Delete Permission
    * 6: View All Permission
    * 7: Modify All Permission
    * @description thenVerifyObjectPermissions
    */
    private static void thenVerifyObjectPermissions() {
        Map<String, Boolean> sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',false);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions('2.00 Agent', sobjPermMap);
        sobjectStepDefinition.thenVerifySobjectPermissions('2.01 Agent Team Member', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',false);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions('2.02 Sales Leader', sobjPermMap);
        sobjectStepDefinition.thenVerifySobjectPermissions('3.01 CCC Unlicensed', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',true);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions('1.06 Business Reporting and Analytics', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',false);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions('3.00 CCC Licensed', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',true);
        sobjPermMap.put('isEditEnabled',true);
        sobjPermMap.put('isDeleteEnabled',true);
        sobjPermMap.put('isViewAllEnabled',true);
        sobjPermMap.put('isModifyAllEnabled',true);
        sobjectStepDefinition.thenVerifySobjectPermissions('System Administrator', sobjPermMap);
    }
    
    
    /**
    * Parmeters for thenVerifyFieldPermissions:
    * 1: Profile or Permission Set Name
    * 2: Field API Name
    * 3: Read Permission
    * 4: Edit Permission
    * @description thenVerifyFieldPermissions
    */
    private static void thenVerifyFieldPermissions() {
        Map<String, Boolean> fieldPermissionsMap = new Map<String, Boolean>();
        fieldPermissionsMap.put('isReadEnabled',true);
        fieldPermissionsMap.put('isEditEnabled',true);  
        Map<String, Boolean> fieldPermissionsMap1 = new Map<String, Boolean>();
        fieldPermissionsMap1.put('isReadEnabled',true);
        fieldPermissionsMap1.put('isEditEnabled',false);  
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Opportunity_Note__c.Comments__c',fieldPermissionsMap);
        verifyFieldPermissions(fieldPermissionsMap1);
    }

    private static void verifyFieldPermissions(Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Opportunity_Note__c.Comments__c',fieldPermissionsMap1);
    }
}