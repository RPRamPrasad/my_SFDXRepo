/**************************
 * @description BDD_Config_Sobject_Case_TEST
     * Scenerio: SysAdmin Creates/deploys Custom Object Cases on Salesforce
     * 
     * Given a Salesforce environment
     * When SysAdmin deploys fields on Object Case
     * Then Object permissions are set appropriately for profiles
     * 
     * Related Stories: S-189266, S-197743
     * 
     * 
     * ***********************/
@isTest
public with sharing class BDD_Config_Sobject_Case_TEST {
 private static BDD_CONFIG_Sobject_StepDefinition sobjectStepDefinition = null;
    @isTest
    static void verifycaseconfigobject() {
        sobjectStepDefinition = new BDD_CONFIG_Sobject_StepDefinition();
        sobjectStepDefinition.givenAdminUser();
        sobjectStepDefinition.whenDeploysSObject('Case');
        thenVerifyObjectPermissions();
        thenVerifyObjectFieldsMetadata();
        thenVerifyFieldPermissions();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    
   /**
    * @description thenVerifyObjectFieldsMetadata
    * Parmeters for thenVerifySobjectHasField:
    * 1. Field Name 2. Field API Name 3. isNillable Field 4. Field Type 5. Field Length
    * 
    * Parmeters for thenVerifySObjectHasRelationship:
    * 1. Field Name 2. Field API Name 3. Relationship Name 4. Reference To 5.isRequired 6. Field Type 
    *
    * Parmeters for thenVerifySObjectPicklistValues:
    * 1. Field Name 2. Field Values(comma seperated) 3. Default Value 4. isRequired
    */ 
    private static void thenVerifyObjectFieldsMetadata() {
        sobjectStepDefinition.thenVerifySobjectHasField ('AgentAssociateId', 'AgentAssociateId__c',false, DisplayType.String, 11);
        Map<String, String> fieldMap = new Map<String, String>();	
        fieldMap.put('fieldLabel','Assigned To');
        fieldMap.put('fieldName','Assigned_To__c');
        fieldMap.put('relationshipName','Assigned_To__r');
        fieldMap.put('referenceTo','User');
        sobjectStepDefinition.thenVerifySObjectHasRelationship (fieldMap,true, DisplayType.Reference);
        
    }
    
    /**
     * @description thenVerifyObjectPermissions
    * Parmeters for thenVerifySobjectPermissions:
    * 1: Profile or Permission Set Name
    * 2: Read Permission
    * 3: Create Permission
    * 4: Edit Permission
    * 5: Delete Permission
    * 6: View All Permission
    * 7: Modify All Permission
    */
    private static void thenVerifyObjectPermissions() {
        Map<String, Boolean> sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',true);
        sobjPermMap.put('isEditEnabled',true);
        sobjPermMap.put('isDeleteEnabled',true);
        sobjPermMap.put('isViewAllEnabled',false);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions ('2.00 Agent', sobjPermMap);
        sobjectStepDefinition.thenVerifySobjectPermissions ('2.01 Agent Team Member', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',false);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions ('2.02 Sales Leader', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',false);
        sobjPermMap.put('isEditEnabled',false);
        sobjPermMap.put('isDeleteEnabled',false);
        sobjPermMap.put('isViewAllEnabled',true);
        sobjPermMap.put('isModifyAllEnabled',false);
        sobjectStepDefinition.thenVerifySobjectPermissions ('1.06 Business Reporting and Analytics', sobjPermMap);
        sobjPermMap = new 	Map<String, Boolean>();
        sobjPermMap.put('isReadEnabled',true);
        sobjPermMap.put('isCreateEnabled',true);
        sobjPermMap.put('isEditEnabled',true);
        sobjPermMap.put('isDeleteEnabled',true);
        sobjPermMap.put('isViewAllEnabled',true);
        sobjPermMap.put('isModifyAllEnabled',true);
        sobjectStepDefinition.thenVerifySobjectPermissions ('3.00 CCC Licensed', sobjPermMap);
        sobjectStepDefinition.thenVerifySobjectPermissions ('3.01 CCC Unlicensed', sobjPermMap);
        sobjectStepDefinition.thenVerifySobjectPermissions ('System Administrator', sobjPermMap);
    }
    
    
    /**
     * @description thenVerifyFieldPermissions
    * Parmeters for thenVerifyFieldPermissions:
    * 1: Profile or Permission Set Name
    * 2: Field API Name
    * 3: Read Permission
    * 4: Edit Permission
    * 
    */
    private static void thenVerifyFieldPermissions() {

        Map<String, Boolean> fieldPermissionsMap = new Map<String, Boolean>();
        fieldPermissionsMap.put('isReadEnabled',true);
        fieldPermissionsMap.put('isEditEnabled',true);
        Map<String, Boolean> fieldPermissionsMap1 = new Map<String, Boolean>();
        fieldPermissionsMap1.put('isReadEnabled',true);
        fieldPermissionsMap1.put('isEditEnabled',false);
        
        // verify field Subject permission
        thenVerifyFieldSubjectPermissions(fieldPermissionsMap);

        // verify field Contact Name permission
        thenVerifyFieldContactNamePermissions(fieldPermissionsMap, fieldPermissionsMap1);
       
        // verify field Account Name permission
        thenVerifyFieldAccountNamePermissions(fieldPermissionsMap, fieldPermissionsMap1);
        
        // verify field Priority permission
        thenVerifyFieldPriorityPermissions(fieldPermissionsMap, fieldPermissionsMap1);

        // verify field Type permission
        thenVerifyFieldTypePermissions(fieldPermissionsMap, fieldPermissionsMap1);

         // verify field Case Reason permission
         thenVerifyFieldCaseReasonPermissions(fieldPermissionsMap, fieldPermissionsMap1);

        // verify field LOB permission
        thenVerifyFieldLOBPermissions(fieldPermissionsMap, fieldPermissionsMap1);

         // verify field Description permission
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.Description',fieldPermissionsMap);
    }   

    private static void thenVerifyFieldSubjectPermissions(Map<String, Boolean> fieldPermissionsMap){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.Subject',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.Subject',fieldPermissionsMap); 
        
    }
    private static void thenVerifyFieldContactNamePermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.ContactId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.ContactId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.ContactId',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.ContactId',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.ContactId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.ContactId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.ContactId',fieldPermissionsMap);
        
    }

    private static void thenVerifyFieldAccountNamePermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.AccountId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.AccountId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.AccountId',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.AccountId',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.AccountId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.AccountId',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.AccountId',fieldPermissionsMap);
    }

    private static void thenVerifyFieldPriorityPermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.Priority',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.Priority',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.Priority',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.Priority',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.Priority',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.Priority',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.Priority',fieldPermissionsMap);
    }
    private static void thenVerifyFieldTypePermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.Type',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.Type',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.Type',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.Type',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.Type',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.Type',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.Type',fieldPermissionsMap);
    }
            
    private static void thenVerifyFieldCaseReasonPermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.Reason',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.Reason',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.Reason',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.Reason',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.Reason',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.Reason',fieldPermissionsMap); 
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.Reason',fieldPermissionsMap);
    }
    private static void thenVerifyFieldLOBPermissions(Map<String, Boolean> fieldPermissionsMap, Map<String, Boolean> fieldPermissionsMap1){
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.00 Agent','Case.LOB__c',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.01 Agent Team Member','Case.LOB__c',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('2.02 Sales Leader','Case.LOB__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('1.06 Business Reporting and Analytics','Case.LOB__c',fieldPermissionsMap1);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.00 CCC Licensed','Case.LOB__c',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('3.01 CCC Unlicensed','Case.LOB__c',fieldPermissionsMap);
        sobjectStepDefinition.thenVerifyFieldPermissions ('System Administrator','Case.LOB__c',fieldPermissionsMap);
    }
    /**
    * @description verifyDaysOpenFormula
	* Verify Days_Open__c Formula field
	*/
    @isTest
    private static void verifyDaysOpenFormula() {       
        Schema.DescribeSObjectResult caseDesc = Case.getSObjectType().getDescribe();
        Schema.DescribeFieldResult caseFieldDesc = caseDesc.fields.getMap().get('Days_Open__c').getDescribe();
        System.assertEquals('TODAY() - DATEVALUE(CreatedDate)', caseFieldDesc.getCalculatedFormula(),'Expected value is TODAY() - DATEVALUE(CreatedDate), but the actual value is '+caseFieldDesc.getCalculatedFormula());
    }

}