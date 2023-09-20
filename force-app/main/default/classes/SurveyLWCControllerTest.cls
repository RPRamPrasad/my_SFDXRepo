@isTest
(seeAllData = false)
private class SurveyLWCControllerTest {
    
    @isTest
    private static void testGetSurveyLinks(){
        Test.startTest();
        Map<String, String> myMap = SurveyLWCController.getSurveyLinks();
        System.assert(myMap.isEmpty(), 'map was not empty');
        System.assert(Limits.getQueries() == 1, 'numbers of queries is wrong');
        Test.stopTest();
    }
    
}