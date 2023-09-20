@isTest
public class DVPremiumChangeResponseTest {
    @isTest private static void test_disc_removed() {
        Case mockChange = new Case();
        List<Case> mockChangeList = new List<Case>();
        mockChangeList.add(mockChange);
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setDiscRemoved(mockChangeList);
        System.assert(premResponse.discRemoved == mockChangeList, premResponse.discRemoved);
    }
    
    @isTest private static void test_disc_changed() {
        Case mockChange = new Case();
        List<Case> mockChangeList = new List<Case>();
        mockChangeList.add(mockChange);
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setDiscChanged(mockChangeList);
        System.assert(premResponse.discChanged == mockChangeList, premResponse.discChanged);
    }
    
    @isTest private static void test_dssi_1() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setDSS('DSS1');
        System.assert(premResponse.dss1 == true, premResponse.dss1);
        System.assert(premResponse.dss2 != true, premResponse.dss2);
        System.assert(premResponse.dss3 != true, premResponse.dss3);
    }

	@isTest private static void test_dssi_2() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setDSS('DSS2');
        System.assert(premResponse.dss1 != true, premResponse.dss1);
        System.assert(premResponse.dss2 == true, premResponse.dss2);
        System.assert(premResponse.dss3 != true, premResponse.dss3);
    }

	@isTest private static void test_dssi_3() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setDSS('DSS3');
        System.assert(premResponse.dss1 != true, premResponse.dss1);
        System.assert(premResponse.dss2 != true, premResponse.dss2);
        System.assert(premResponse.dss3 == true, premResponse.dss3);
    }
    
    @isTest private static void test_dss_message_wa() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setStateDSSMessage('47');
        System.assert(premResponse.isWA == true, premResponse.isWA);
        System.assert(premResponse.isNY != true, premResponse.isNY);
        System.assert(premResponse.isOther != true, premResponse.isOther);
    }
    
    @isTest private static void test_dss_message_ny_32() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setStateDSSMessage('32');
        System.assert(premResponse.isWA != true, premResponse.isWA);
        System.assert(premResponse.isNY == true, premResponse.isNY);
        System.assert(premResponse.isOther != true, premResponse.isOther);
    }
    
    @isTest private static void test_dss_message_ny_52() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setStateDSSMessage('52');
        System.assert(premResponse.isWA != true, premResponse.isWA);
        System.assert(premResponse.isNY == true, premResponse.isNY);
        System.assert(premResponse.isOther != true, premResponse.isOther);
    }
    
    @isTest private static void test_dss_message_other() {
        DVPremiumChangeResponse premResponse = new DVPremiumChangeResponse();
        premResponse.setStateDSSMessage('99');
        System.assert(premResponse.isWA != true, premResponse.isWA);
        System.assert(premResponse.isNY != true, premResponse.isNY);
        System.assert(premResponse.isOther == true, premResponse.isOther);
    }
}