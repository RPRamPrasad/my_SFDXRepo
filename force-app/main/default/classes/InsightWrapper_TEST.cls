@isTest()
public class InsightWrapper_TEST {
	@isTest
    static void  insightWrapperMethod(){
        
        Test.startTest();
            InsightWrapper wrap = new InsightWrapper();
			wrap.claimMapList = null;
            wrap.insightList = null;
            wrap.pastDueMapList = null;
        	system.assertequals(null,wrap.claimMapList);
        Test.stopTest();
        
    }
   
}