@IsTest
private class Test_AT_ClaimProviderSearchController {
    @IsTest
    static void checkStateList(){     
        
        Test.startTest();
        List<String> listOfStates =  AT_ClaimProviderSearchController.fetchStates('USA');       
        Test.stopTest();
        System.assertEquals([SELECT MasterLabel FROM CM_US_Canada_State__mdt WHERE Is_State__c = true AND Address_Type__c = 'USA'].size(), listOfStates.size(), 'List of states size was not equal');
       
    }   
}
