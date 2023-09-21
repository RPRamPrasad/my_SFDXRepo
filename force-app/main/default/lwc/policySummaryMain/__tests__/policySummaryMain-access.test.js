import { getRecord } from 'lightning/uiRecordApi';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);

import policySummaryMain from 'c/policySummaryMain';
import fetchAllPolicies from '@salesforce/apex/PolicySummaryQueryController.fetchAllPolicies';
import fetchUserPreference from '@salesforce/apex/PolicySummaryPreferenceController.fetchUserPreference';
import getAccountIdsForHouseholdFSC from '@salesforce/apex/BillingActionsController.getRecordIdsForHousehold';
import getPLMStatus from '@salesforce/apex/InsurancePolicyController.getPLMStatus';

import mockAccount from './data/mockAccount.json';
import mockDataPolicies from './data/policyTestData.json';
import mockHouseholdData from './data/householdData.json';

const mockAccess = {
     'PolicyActions_PolicyTransactions': { read: true},
     'PolicyActions_AutoIDCard': { read: true},
     'PolicyActions_BillingOnlineSystem': {read: true},
     'PolicyActions_CertificateOfInsurance': {read: true}
  };
  
  jest.mock('c/checkFeatureAccess', () => {
      return {
          getFeatureAccessMetadataBySubuserType: jest.fn(featureName => Promise.resolve(mockAccess[featureName])),
          getFeatureAccessMetadataByUserCriteria: jest.fn(featureName => Promise.resolve(mockAccess[featureName]))
  
      };
  });

  

  jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPLMStatus',
    () => { return { default: jest.fn() }; },
    { virtual: true }
   
);

jest.mock(
    '@salesforce/apex/PolicySummaryQueryController.fetchAllPolicies',
    () => { return { default: jest.fn() }; },
    { virtual: true }
  );
  
  jest.mock(
    '@salesforce/apex/PolicySummaryPreferenceController.fetchUserPreference',
    () => { return { default: jest.fn() }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/customPermission/Case_Migration_Pilot_User',
    () => { return { default: true }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/customPermission/PolicySummary_SupportAccess',
    () => { return { default: false }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/customPermission/PolicySummary_EarlyAccess',
    () => { return { default: false }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/apex/BillingActionsController.getRecordIdsForHousehold',
    () => { return { default: jest.fn() }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/apex/InsurancePolicyController.logException',
    () => { return { default: jest.fn() }; },
    { virtual: true }
  );

  jest.mock(
    '@salesforce/apex/PolicySummaryPreferenceController.updateUserView',
    () => { return { default: jest.fn() }; },
    { virtual: true }
  );
  
  function setup(recordId, acctRecord, policyCardView, policyListView) {
    let policySummaryMainComp;
    policySummaryMainComp = createElement('c-policy-summary-main', { is: policySummaryMain });
    policySummaryMainComp.recordId = recordId;
    policySummaryMainComp.policyCardView = policyCardView;
    policySummaryMainComp.policyListView = policyListView;
    document.body.appendChild(policySummaryMainComp);

    return policySummaryMainComp;
}

  describe('c-policy-summary-main', () => {
  
    afterEach(() => {
      while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
      }
      jest.clearAllMocks();
      jest.resetModules();
    })
  
    const { setImmediate } = require('timers')
  function flushPromises() {
      
      return new Promise(resolve => setImmediate(resolve));
    }
    

    it('handle access true', async () => {
        getPLMStatus.mockResolvedValue({ PLM_Auto_Launch_PC_Active__c: true, PLM_Opp_Redirect_Active__c: true, PLM_Policy_Actions_Active__c: true })
        fetchAllPolicies.mockResolvedValue(mockDataPolicies);
        fetchUserPreference.mockResolvedValue("policy-card");
        getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
        const element = setup('HAPPYPATH', mockAccount,true,false);
        getRecordWireAdapter.emit(mockAccount);

        await flushPromises();
       
        return Promise.resolve().then(() => {
            const policyNumber  = mockDataPolicies[0].Name;
            const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
            expect(policyElement.policy.Name).toBe(policyNumber);
            expect(policyElement.userAccess.hasPolicyTransactionAccess).toBe(true);
            expect(policyElement.userAccess.hasAutoIdCardAccessforSubuserType).toBe(true);
            expect(policyElement.userAccess.hasAutoIdCardAccessforUserCriteria).toBe(true);
            expect(policyElement.userAccess.hasBOSLinkAccess).toBe(true);
            expect(policyElement.userAccess.hasCOILinkAccess).toBe(true);
            expect(policyElement.plmActivationStatus.isOppRedirectActive).toBe(true);
            expect(policyElement.plmActivationStatus.isPCAutoLaunchActive).toBe(true);
            expect(policyElement.plmActivationStatus.isPolicyActionsActive).toBe(true);
           
      
          })

    });

    it('calls enhance policy on all child card LWCs', async () => {
      fetchAllPolicies.mockResolvedValue(mockDataPolicies);
      fetchUserPreference.mockResolvedValue("policy-card");
      getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
      getPLMStatus.mockResolvedValue({
        PLM_Opp_Redirect_Active__c: false,
        PLM_Auto_Launch_PC_Active__c: false,
        PLM_Policy_Actions_Active__c: false
      })
      const element = setup('HAPPYPATH', mockAccount, true, false);
      getRecordWireAdapter.emit(mockAccount);
  
      await flushPromises();
  
      const enhanceButton = element.shadowRoot.querySelector('[data-id="enhanceAllButton"]');
      expect(enhanceButton).toBeTruthy();
    });
});