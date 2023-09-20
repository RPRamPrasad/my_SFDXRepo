/*************************************************************************
* 
*  @description Checks that knowledge is enabled for objects returned by globalDescription
*  Lightning will only use Ka type records for articles.
*  Classic had used a different type.
*  This tests to make sure only Lightning records exist.  All classic get converted with lightning
*
* ************************************************************************/
@isTest (seeAllData=false)
public class BDD_Lightning_Knowledge_TEST {
    @isTest
    static void testKnowledgeEnabled(){
         
        for (Schema.SObjectType o : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult obj = o.getDescribe();
            if (obj.isDeprecatedAndHidden()) {
                continue;
            }
            if (obj.getKeyPrefix() != null && Pattern.matches('ka[0-9]',obj.getKeyPrefix())) {
                String objName = obj.getName();
                try {
                    fetchData(objName);                
                } catch (QueryException e) {
                    if (e.getMessage().contains('No such column')) {
                        System.assert(true, 'Lightning Knowledge enabled.  No classis articles available.');                    
                    }
                    else{
                        System.assert(false,'Classic Knowledge is still enabled');
                    }                                  
                }            
            }            
        }     
    }
    private static void fetchData(String objName){
      Database.query('SELECT Id, ArticleType FROM ' + objName);   
    }
}