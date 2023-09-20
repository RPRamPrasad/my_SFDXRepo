/**
 * @className: AP_TranscriptProcess_TEST
 * @description This is the test class checking code coverage for class AP_TranscriptProcess
 * @Author: Team ITIC
 */
@isTest
(seeAllData = false)
public with sharing class AP_TranscriptProcess_TEST {
    @isTest
    static void testEqualsSet(){
        Set<AP_TranscriptProcess> participantSet =  new Set<AP_TranscriptProcess>();
        AP_TranscriptProcess.TranscriptUserDataWrapperList transcriptTestUserP1Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			transcriptTestUserP1Wrap.uniqueKey = 'TEST1@test.com';
			transcriptTestUserP1Wrap.pEmail = 'TEST1@test.com';
			transcriptTestUserP1Wrap.pName = 'NAME1';
			transcriptTestUserP1Wrap.pAlias = 'ALIAS1';
			transcriptTestUserP1Wrap.pTitle = 'TITLE1';
			transcriptTestUserP1Wrap.pId = 'RECORDID1';
		AP_TranscriptProcess p1 =  new AP_TranscriptProcess(transcriptTestUserP1Wrap);
        AP_TranscriptProcess.TranscriptUserDataWrapperList transcriptTestUserP2Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			transcriptTestUserP2Wrap.uniqueKey = 'TEST2@test.com';
			transcriptTestUserP2Wrap.pEmail = 'TEST2@test.com';
			transcriptTestUserP2Wrap.pName = 'NAME2';
			transcriptTestUserP2Wrap.pAlias = 'ALIAS2';
			transcriptTestUserP2Wrap.pTitle = 'TITLE2';
			transcriptTestUserP2Wrap.pId = 'RECORDID2';
		AP_TranscriptProcess p2 =  new AP_TranscriptProcess(transcriptTestUserP2Wrap);
        AP_TranscriptProcess.TranscriptUserDataWrapperList transcriptTestUserP3Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			transcriptTestUserP3Wrap.uniqueKey = 'TEST1@test.com';
			transcriptTestUserP3Wrap.pEmail = 'TEST1@test.com';
			transcriptTestUserP3Wrap.pName = 'NAME';
			transcriptTestUserP3Wrap.pAlias = 'ALIAS';
			transcriptTestUserP3Wrap.pTitle = 'TITLE';
			transcriptTestUserP3Wrap.pId = 'RECORDID1';
		AP_TranscriptProcess p3 =  new AP_TranscriptProcess(transcriptTestUserP3Wrap);
        Test.startTest();
        participantSet.add(p1);
        participantSet.add(p2);
        participantSet.add(p3);
        p1.hashcode();
        Test.stopTest();
        System.assertEquals(2,participantSet.size(), 'Size of the participant set is 2');
    }

    @isTest
    static void testEqualsMap(){
    	Map<AP_TranscriptProcess,String> m =  new Map<AP_TranscriptProcess,String>();
    	AP_TranscriptProcess.TranscriptUserDataWrapperList mapTranscriptTestUserP1Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			mapTranscriptTestUserP1Wrap.uniqueKey = 'TEST1@test.com';
			mapTranscriptTestUserP1Wrap.pEmail = 'TEST1@test.com';
			mapTranscriptTestUserP1Wrap.pName = 'NAME1';
			mapTranscriptTestUserP1Wrap.pAlias = 'ALIAS1';
			mapTranscriptTestUserP1Wrap.pTitle = 'TITLE1';
			mapTranscriptTestUserP1Wrap.pId = 'RECORDID1';
		AP_TranscriptProcess p1 =  new AP_TranscriptProcess(mapTranscriptTestUserP1Wrap);
        AP_TranscriptProcess.TranscriptUserDataWrapperList mapTranscriptTestUserP2Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			mapTranscriptTestUserP2Wrap.uniqueKey = 'TEST2@test.com';
			mapTranscriptTestUserP2Wrap.pEmail = 'TEST2@test.com';
			mapTranscriptTestUserP2Wrap.pName = 'NAME2';
			mapTranscriptTestUserP2Wrap.pAlias = 'ALIAS2';
			mapTranscriptTestUserP2Wrap.pTitle = 'TITLE2';
			mapTranscriptTestUserP2Wrap.pId = 'RECORDID2';
		AP_TranscriptProcess p2 =  new AP_TranscriptProcess(mapTranscriptTestUserP2Wrap);
        AP_TranscriptProcess.TranscriptUserDataWrapperList mapTranscriptTestUserP3Wrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			mapTranscriptTestUserP3Wrap.uniqueKey = 'TEST1@test.com';
			mapTranscriptTestUserP3Wrap.pEmail = 'TEST1@test.com';
			mapTranscriptTestUserP3Wrap.pName = 'NAME';
			mapTranscriptTestUserP3Wrap.pAlias = 'ALIAS';
			mapTranscriptTestUserP3Wrap.pTitle = 'TITLE';
			mapTranscriptTestUserP3Wrap.pId = 'RECORDID1';
		AP_TranscriptProcess p3 =  new AP_TranscriptProcess(mapTranscriptTestUserP3Wrap);
        Test.startTest();
        m.put(p1,'first');
        m.put(p2,'second');
        m.put(p3,'third');
        Test.stopTest();
        system.assertEquals(true,m.containsKey(p1), 'contains key p1 is true');
        system.assertEquals(true,m.containsKey(p2), 'contains key p2 is true');
        AP_TranscriptProcess.TranscriptUserDataWrapperList mapTranscriptTestUserWrap = new AP_TranscriptProcess.TranscriptUserDataWrapperList();
			mapTranscriptTestUserWrap.uniqueKey = 'TEST3@test.com';
			mapTranscriptTestUserWrap.pEmail = 'TEST3@test.com';
			mapTranscriptTestUserWrap.pName = 'NAME3';
			mapTranscriptTestUserWrap.pAlias = 'ALIAS3';
			mapTranscriptTestUserWrap.pTitle = 'TITLE3';
			mapTranscriptTestUserWrap.pId = 'RECORDID3';
		system.assertEquals(false,m.containsKey(new AP_TranscriptProcess(mapTranscriptTestUserWrap)), 'contains key will have transcriptprocess record');
    }
}