/**
  * @author: Targaryen
  * @owner: Targaryen
  * @name: UTIL_SubQueryBuilder
  * @createdDate: 04/22/2020
  * @description: The class will generate subQuery string from Configuration.
  * @version 1.0
  */
  /**
   * @description UTIL_SubQueryBuilder
   */

 public without sharing class UTIL_SubQueryBuilder {
  private static final String SELECT_ID = 'SELECT Id';
  private static final String OPEN_PARENTHESIS = '(';
  private static final String CLOSE_PARENTHESIS = ')';
  private static final String QUERY_FROM = 'FROM';
  private static final String COMMA =',';
  private static final String EMPTY_STRING = ' ';

/**
* @description: The method will build and return queryString from defined configuration in Custom Metadata Type
* @author: Targaryen .SFDoc | 5/11/2020
* @param: listOfConfigObjects
* @return: string
**/

/**
 *
 * @param listOfConfigObjects
 * @description buildDynamicSubQueryStringFromConfiguration(List<CM_SubQuery_Object_Settings__mdt> listOfConfigObjects)
 * @return  string
 */
public static string buildDynamicSubQueryStringFromConfiguration(List<CM_SubQuery_Object_Settings__mdt> listOfConfigObjects){
  String subQueryString = '';

  for (CM_SubQuery_Object_Settings__mdt singleObject : listOfConfigObjects){
      subQueryString += OPEN_PARENTHESIS+SELECT_ID+COMMA+singleObject.SObject_Field_Name__c+EMPTY_STRING+QUERY_FROM+
                        EMPTY_STRING+singleObject.SObject_Plural_Name__c+EMPTY_STRING+CLOSE_PARENTHESIS+COMMA;
  }
  subQueryString = subQueryString.removeEnd(COMMA);
  return subQueryString;
}
}