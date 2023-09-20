//Author : Tamil Lakshmi
//Desc : Created by Smart CRM team to enable to click for Insight Indicator
/**
 * @description This class will process enable to click for Insight Indicator
 */
public with sharing class InsightClickHandler {
  private static final String ATTRIBUTE_DETAILS = 'attributedetails';
  /**
   * @description This method will process the getclickDetails
   * @param clickDetailsWrapper
   * @return  `Map<string,object>`
   */
  @AuraEnabled
  public static Map<string,object> getclickDetails(GetClickDetailWrapperList clickDetailsWrapper) {
    String targetValue = clickDetailsWrapper.targetValue;
    String clickLabel = clickDetailsWrapper.clickLabel;
    Map<string,object> returnMap = new Map<string,object> ();
    String attributedetails = '';
    try {
      attributedetails = attributedetail(targetValue,returnMap,attributedetails);
      buildReturnMap(clickDetailsWrapper,returnMap,attributedetails);

      CM_Toggle__mdt metricsToggle = CM_Toggle__mdt.getInstance('Insight_Metrics_Toggle');
      if(metricsToggle.Enabled__c)
      {
        InsightMetricsHandler.recordClicks(clickLabel,targetValue);
      }
    } catch(Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return returnMap;
  }

    /**
   * @description This method will process the getclickDetails into the returnMap
   * @param clickDetailsWrapper
   * @param returnMap
   * @param attributedetails
   */
  public static void buildReturnMap(GetClickDetailWrapperList clickDetailsWrapper,Map<string,object> returnMap, String attributedetails){
    switch on clickDetailsWrapper.targetValue{
      when 'New Simple Conversation' {
        returnMap.put(ATTRIBUTE_DETAILS, clickDetailsWrapper.url  + attributedetails + clickDetailsWrapper.accountId);
      }
      when 'Meet Now' {
        returnMap.put(ATTRIBUTE_DETAILS, clickDetailsWrapper.url  + attributedetails + clickDetailsWrapper.accountId);
      }
      when ('Simple Conversation - ABS') {
        returnMap.put(ATTRIBUTE_DETAILS, attributedetails);
      }
      when ('Customer Retention - ABS') {
        returnMap.put(ATTRIBUTE_DETAILS, attributedetails);
      }
      when ('Pay Bill(s)') {
        returnMap.put(ATTRIBUTE_DETAILS, attributedetails);
      }
      when 'Claims Capabilities' {
        returnMap.put(ATTRIBUTE_DETAILS, attributedetails);
      }
      when 'View Program Details' {
        returnMap.put(ATTRIBUTE_DETAILS,  clickDetailsWrapper.url  + attributedetails + clickDetailsWrapper.accountId);
      }
      when else {
        returnMap.put('typedetails','standard__recordPage');
        returnMap.put(ATTRIBUTE_DETAILS,attributedetails);
      }
    }
  }

  /**
   * @description This is a wrapper class will process the GetClickDetailWrapperList
   */
  public class GetClickDetailWrapperList{
    /**
     * @description getters and setters for targetvalue
     */
    @AuraEnabled
		public String targetValue {get;set;}
    /**
     * @description getters and setters for accountid
     */
    @AuraEnabled
		public Id accountId {get;set;}
    /**
     * @description getters and setters for url
     */
    @AuraEnabled
		public String url {get;set;}
    /**
     * @description getters and setters for clicklabel
     */
    @AuraEnabled
		public String clickLabel {get;set;}
	}

  /**
   * @description This method will process the attributedetail
   * @param targetValue
   * @param returnMap
   * @param attributedetails
   * @return  `static`
   */
  public static String attributedetail(String targetValue,Map<string,object> returnMap,String attributedetails){
    List<Insight_Dropdown__mdt> mdtVal = Insight_Dropdown__mdt.getAll().values();
    String tmp = attributedetails;
		for(Integer r = 0; r < mdtVal.size(); r++){
			if (mdtVal[r].Label.equalsIgnoreCase(targetValue)){
				returnMap.put('typedetails', mdtVal[r].Type__c);
				tmp = mdtVal[r].Attribute__c;
			}
		}
      return tmp;
	}
}