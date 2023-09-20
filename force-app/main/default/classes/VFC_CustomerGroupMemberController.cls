/****************************************************************************************
Name: VFC_CustomerGroupMemberController
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group Member Details page.

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                1/18/2018             2018 R1 Release

******************************************************************************************/

/**
 * @description VFC Customer Group Member Controller
 */
public with sharing class VFC_CustomerGroupMemberController {
 
  private static final String ID_PARAM = 'Id';
  private static final String ACC_ID_PARAM = 'accIdInContext';
  private static final String RETURL_PARAM = 'retUrl';
  private static final String S1_THEME = 'Theme4t';

  /**
   * @description getters and setters of custGrpMemberRecord
   * @return CustomerGroupMember__c
   */
  public CustomerGroupMember__c custGrpMemberRecord {get; set;}

  /**
   * @description getters and setters of redirectUrl
   * @return String
   */
  public String redirectUrl {get; private set;}
  
  /**
   * @description VFC Customer Group Member Controller
   * @param stdController
   */
  public VFC_CustomerGroupMemberController(ApexPages.StandardController stdController) {
       AP_ClickJackPrevention.setRequiredHeaders();
       custGrpMemberRecord = (CustomerGroupMember__c)stdController.getRecord();
       List<CustomerGroupMember__c> custgrpMemberList = Security.stripInaccessible(AccessType.READABLE ,[SELECT id, name, Group__c, Customer__c FROM CustomerGroupmember__c WHERE id = :custGrpMemberRecord.id LIMIT 1]).getRecords();
       if(!(custgrpMemberList == null || custgrpMemberList.isEmpty())) {
          custGrpMemberRecord = custgrpMemberList.get(0);
       }
  }
  	
  /**
   * @description Init
   * @return PageReference
   */
  public PageReference init(){
	PageReference groupDetailPage = Page.VFP_CustomerGroupDetail;
	groupDetailPage.getParameters().put(ID_PARAM, custGrpMemberRecord.Group__c);
	groupDetailPage.getParameters().put(ACC_ID_PARAM, custGrpMemberRecord.Customer__c);
	groupDetailPage.getParameters().put(RETURL_PARAM, UTIL_CreateCustomerConstants.SLASH + custGrpMemberRecord.Customer__c);
	redirectUrl = groupDetailPage.getUrl();
	if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())){
    	groupDetailPage = null;
    }
    else {
		groupDetailPage.setRedirect(true);
    }
	return groupDetailPage;
  }
}