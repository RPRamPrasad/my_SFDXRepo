/**
  * @author: Targaryen
  * @owner: Targaryen
  * @name: UTIL_QueryBuilderForACR
  * @createdDate: 06/15/2020
  * @description The class will help to get SOQL Query Results for ACR.
  * @version 1.0
  */
 public without sharing class UTIL_QueryBuilderForACR {
  private static final String EMPTY_STRING = ' ';
  private static final String FIELDS_TO_POPULATE_FROM_ACCOUNT = 'SELECT Id, Primary_Household__pc, Name';
  private static final String COMMA = ',';
  private static final String WHERE_CLAUSE = 'WHERE Id IN ';
  private static final String QUERY_FROM_ACCOUNT = 'FROM Account';
  
  /**
  * @description The method will fetch list of accounts with Child records configured in Custom Meta Data using SOQL Query
  * @author: Targaryen.SFDoc | 6/15/2020 
  * @param listOfConfigObjects 
  * @param listofAccountIds 
  * @return List<sObject> 
  **/
  public static List<sObject> getListofAccountRecordsWithChild(List<CM_SubQuery_Object_Settings__mdt> listOfConfigObjects,Set<Id> listofAccountIds){       
      String subQueryString = UTIL_SubQueryBuilder.buildDynamicSubQueryStringFromConfiguration(listOfConfigObjects);
      String soqlQueryString = FIELDS_TO_POPULATE_FROM_ACCOUNT + COMMA + subQueryString + EMPTY_STRING+ QUERY_FROM_ACCOUNT + EMPTY_STRING + WHERE_CLAUSE;       
      soqlQueryString+=':listofAccountIds';
      List<sObject> listofAccountRecordsWithChild = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(soqlQueryString))).getRecords();
      return listofAccountRecordsWithChild;
  }
}