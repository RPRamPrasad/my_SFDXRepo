/**
 * @className: BDD_CONFIG_SObject_OppMetadata_TEST
 * @description : Test Opportunity custom fields
 * @Author: Team Poseidon
 */
@isTest(SeeAllData = false)
public class BDD_CONFIG_SObject_OppMetadata_TEST {
	
    private static BDD_CONFIG_Sobject_StepDefinition sobjectStepDefinition;
    
    private static void sobjectSetUp() {       
        sobjectStepDefinition = new BDD_CONFIG_Sobject_StepDefinition();          
       	sobjectStepDefinition.whenDeploysSObject('Opportunity'); 
    }
    
    @isTest
    private static void verifyIsNextStepAdded() {
        sobjectSetUp();  
        sobjectStepDefinition.thenVerifySobjectHasField('Is Next Step Added', 'Is_Next_Step_Added__c',true, DisplayType.Boolean, 1);
        Map<String, Boolean> fieldPermissionsMap1 = new Map<String, Boolean>();
        fieldPermissionsMap1.put('isReadEnabled',true);
        fieldPermissionsMap1.put('isEditEnabled',false);
        sobjectStepDefinition.thenVerifyFieldPermissions('System Administrator', 'Opportunity.Is_Next_Step_Added__c', fieldPermissionsMap1);
        Schema.DescribeSObjectResult oppDesc = Opportunity.getSObjectType().getDescribe();
        Schema.DescribeFieldResult oppFieldDesc = oppDesc.fields.getMap().get('Is_Next_Step_Added__c').getDescribe();
        System.assertEquals('NOT(ISBLANK(NextStepDate__c))', oppFieldDesc.getCalculatedFormula(),'Expected value is NOT(ISBLANK(NextStepDate__c)), but actual value is '+oppFieldDesc.getCalculatedFormula());
    }
    
    @isTest
    private static void verifyTotalQuoteAttached() {        
        sobjectSetUp();
        sobjectStepDefinition.thenVerifySobjectHasField('Total Quote Attached', 'Total_Quote_Attached__c',false, DisplayType.Double, 2);
        Map<String, Boolean> fieldPermissionsMap1 = new Map<String, Boolean>();
        fieldPermissionsMap1.put('isReadEnabled',true);
        fieldPermissionsMap1.put('isEditEnabled',false);     
        sobjectStepDefinition.thenVerifyFieldPermissions('System Administrator', 'Opportunity.Total_Quote_Attached__c', fieldPermissionsMap1);     
    }
}