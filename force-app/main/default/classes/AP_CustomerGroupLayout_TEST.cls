/**
  * @name AP_CustomerGroupLayout_TEST
  * @author  Poseidon
  * @createdDate 08/29/2018
  * @description Apex Testing for Customer Group object Page Layout
  */
@isTest (seeAllData=false)
public class AP_CustomerGroupLayout_TEST {

    private static final String CUSTOMER_GROUP_LAYOUT = 'CustomerGroup__c-Customer Group Layout';

	/**
    *@description -This method will get sObject PageLayout by layoutName
    *@name -getPageLayout
	*@param layoutName
	*@return - List<Metadata.Metadata>
	*@author -Poseidon
    */
    private static List<Metadata.Metadata> getPageLayout(String layoutName){
        List<String> componentNameList = new List<String>{layoutName};
		List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        return components;
    }

   /**
    *@description This method will verify the fields on the CustomerGroupLayout
    *@name -verifyCustomerGroupLayout
	*@author -Poseidon
    */
    @isTest
    static void verifyCustomerGroupLayout(){

        Metadata.Layout customerGroupLayout = (Metadata.Layout) getPageLayout(CUSTOMER_GROUP_LAYOUT).get(0);
        List<Metadata.LayoutItem> detailsColumnOne = customerGroupLayout.layoutSections[0].layoutColumns[0].layoutItems;
        List<Metadata.LayoutItem> detailsColumnTwo = customerGroupLayout.layoutSections[0].layoutColumns[1].layoutItems;
        List<Metadata.LayoutItem> customerGroupInfoColumn = customerGroupLayout.layoutSections[3].layoutColumns[0].layoutItems;

        System.assertEquals('Name', detailsColumnOne[0].field, 'Name field is incorrect or not in the correct place');
        System.assertEquals('CreatedById', detailsColumnOne[1].field, 'Created By field is incorrect or not in correct place');
        System.assertEquals('GroupCategory__c', detailsColumnTwo[0].field, 'Group Category field is incorrect or not in the correct place');
        System.assertEquals('LastModifiedById', detailsColumnTwo[1].field, 'Last Modified By field is incorrect or not in correct place');
        System.assertEquals('HouseholdComments__c', customerGroupInfoColumn[0].field, 'Group Comments field is incorrect or not in correct place');

    }
}