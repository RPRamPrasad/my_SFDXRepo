import { getRecord } from 'lightning/uiRecordApi';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);

import policySummaryMain from 'c/policySummaryMain';
import fetchAllPolicies from '@salesforce/apex/PolicySummaryQueryController.fetchAllPolicies';
import fetchUserPreference from '@salesforce/apex/PolicySummaryPreferenceController.fetchUserPreference';
import updateUserView from '@salesforce/apex/PolicySummaryPreferenceController.updateUserView';
import logException from '@salesforce/apex/InsurancePolicyController.logException';
import getAccountIdsForHouseholdFSC from '@salesforce/apex/BillingActionsController.getRecordIdsForHousehold';
import getPLMStatus from '@salesforce/apex/InsurancePolicyController.getPLMStatus';
import getGroupPolicyStatus from '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus';

import logClickActiveInactiveSlider from '@salesforce/apex/PolicySummaryEventController.logClickActiveInactiveSlider';
import logClickCollapseAll from '@salesforce/apex/PolicySummaryEventController.logClickCollapseAll';
import logClickExpandAll from '@salesforce/apex/PolicySummaryEventController.logClickExpandAll';
import logSetAlert from '@salesforce/apex/PolicySummaryEventController.logSetAlert';
import logClickAlert from '@salesforce/apex/PolicySummaryEventController.logClickAlert';
import logClickEnhanceAll from '@salesforce/apex/PolicySummaryEventController.logClickEnhanceAll';

import mockAccount from './data/mockAccount.json';
import mockAccountNoClient from './data/mockAccountNoClient.json';
import mockDataPolicies from './data/policyTestData.json';
import mockDataPoliciesWithAlert from './data/policyTestDataWithAlert.json';
import mockHouseholdData from './data/householdData.json';

const mockAccess = {
  'PolicyActions_PolicyTransactions': { read: false },
  'PolicyActions_AutoIDCard': { read: false },
  'PolicyActions_BillingOnlineSystem': { read: false },
  'PolicyActions_CertificateOfInsurance': { read: false }
};

//#region Mocks

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
  () => { return { default: false }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/customPermission/PolicySummary_SupportAccess',
  () => { return { default: true }; },
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

jest.mock(
  '@salesforce/apex/InsurancePolicyController.getGroupPolicyStatus',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logClickActiveInactiveSlider',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logClickCollapseAll',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logClickExpandAll',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logSetAlert',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logClickAlert',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);

jest.mock(
  '@salesforce/apex/PolicySummaryEventController.logClickEnhanceAll',
  () => { return { default: jest.fn() }; },
  { virtual: true }
);


//#endregion

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

  it('handleExpand with card view', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount, true, false);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    expect(logException).not.toHaveBeenCalled();

    return Promise.resolve().then(() => {
      const handleExpandElement = element.shadowRoot.querySelector('[data-id="handle-expand"]');
      handleExpandElement.click();
      expect(handleExpandElement).not.toBeNull();
      const activeAccordionsElements = element.shadowRoot.querySelector('lightning-accordion');
      expect(activeAccordionsElements.activeSectionName).toEqual(activeSections);
      const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
      const inactivePolicyElement = element.shadowRoot.querySelector('[key="0YT2C0000008QVqWWW"]');
      expect(inactivePolicyElement).toBeNull();
      expect(activeSectionElements).not.toBeNull();
      expect(activeSectionElements).toHaveLength(4);
      expect(activeSectionElements[0].name).toEqual('Auto');
      expect(activeSectionElements[1].name).toEqual('Fire');
      expect(activeSectionElements[2].name).toEqual('Life');
      expect(activeSectionElements[3].name).toEqual('Health');
      const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
      expect(policyElements).not.toBeNull();
      expect(policyElements).toHaveLength(4);
      policyElements.forEach(policyElement => {
        expect(policyElement).not.toContain("10-JJ-D128-8")
      });

      const policyListElements = element.shadowRoot.querySelectorAll('[data-id="policy-list"]');
      expect(policyListElements).toHaveLength(0);

      expect(logClickActiveInactiveSlider).not.toBeCalled();
      expect(logClickCollapseAll).not.toBeCalled();
      expect(logClickExpandAll).toBeCalled();

      expect(fetchAllPolicies).toHaveBeenCalledWith({ inputRecordId: 'HAPPYPATH', inputRecordTypeId: 'sfdcAccountTypeId' })
    })

  });

  it('handle card view as default', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const handleExpandElement = element.shadowRoot.querySelector('[data-id="handle-expand"]');
      handleExpandElement.click();
      expect(handleExpandElement).not.toBeNull();
      const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
      expect(activeSectionElements).not.toBeNull();
      expect(activeSectionElements).toHaveLength(4);
      activeSectionElements.forEach(activeSection => {
        expect(activeSections).toContain(activeSection.name);
      })

      expect(getAccountIdsForHouseholdFSC).not.toHaveBeenCalled();
    })
  });

  it('handleExpand with list view', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-list");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const element = setup('HAPPYPATH', mockAccount, false, true);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const handleExpandElement = element.shadowRoot.querySelector('[data-id="handle-expand"]');
      expect(handleExpandElement).toBeNull();
      const policyListElements = element.shadowRoot.querySelectorAll('[data-id="policy-list"]');
      expect(policyListElements).not.toBeNull();
      expect(policyListElements).toHaveLength(4);
      policyListElements.forEach(policyElement => {
        expect(policyElement).not.toContain("10-JJ-D128-8")
      });

      const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
      expect(policyElements).toHaveLength(0);
    })
  });

  it('handleCollapse with card view', async () => {
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

    return Promise.resolve().then(async () => {
      const handleCollapseElement = element.shadowRoot.querySelector('[data-id="handle-collapse"]');
      handleCollapseElement.click();

      await flushPromises();

      expect(handleCollapseElement).not.toBeNull();

      expect(logClickActiveInactiveSlider).not.toBeCalled();
      expect(logClickCollapseAll).toBeCalled();
      expect(logClickExpandAll).not.toBeCalled();

      const accordionSectionsElement = element.shadowRoot.querySelector('lightning-accordion');
      expect(accordionSectionsElement.activeSectionName).toEqual([]);
    })

  });

  it('handleCollapse with list view', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-list");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount, false, true);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const handleCollapseElement = element.shadowRoot.querySelector('[data-id="handle-collapse"]');
      const handleCollapseElement1 = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(handleCollapseElement).toBeNull();
      expect(handleCollapseElement1).toBeNull();


    })

  });

  it('handle toggle checked with card view', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const element = setup('HAPPYPATH', mockAccount, true, false);
    let spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
    expect(spinnerElement).toBeTruthy();
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(async () => {
      const toggleElement = element.shadowRoot.querySelector('[data-id="toggle-status"]');
      expect(toggleElement).not.toBeNull();
      toggleElement.checked = false;
      const onChangeEvent = new CustomEvent("change");
      toggleElement.dispatchEvent(onChangeEvent);

      await flushPromises();

      return Promise.resolve().then(() => {
        expect(logClickActiveInactiveSlider).toHaveBeenCalled();
        expect(logException).not.toHaveBeenCalled();
        const noPolicies = element.shadowRoot.querySelector('span[data-id="no-policies"]')
        expect(noPolicies).toBeFalsy();
        
        const policyElements = element.shadowRoot.querySelectorAll('c-policy-summary-card[data-id="policy"]');
        expect(policyElements).not.toBeNull();
        expect(policyElements).toHaveLength(4);
        expect(policyElements[0].policy.Name).toBe('137 6408-E20-31');
        policyElements.forEach(policyElement => {
          expect(policyElement.isHousehold).toBe(false);
          expect(policyElement).not.toContain("10-JJ-D128-8")
        });
        const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
        expect(activeSectionElements).not.toBeNull();
        expect(activeSectionElements).toHaveLength(4);
        activeSectionElements.forEach(activeSection => {

          expect(activeSections).toContain(activeSection.name);


        })

        spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
        expect(spinnerElement).toBeFalsy();
      })
        
    })

  });

  it('handle toggle with no client id', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount, true, false);
    let spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
    expect(spinnerElement).toBeTruthy();
    getRecordWireAdapter.emit(mockAccountNoClient);

    await flushPromises();

    return Promise.resolve().then(async() => {
      const toggleElement = element.shadowRoot.querySelector('[data-id="toggle-status"]');
      expect(toggleElement).not.toBeNull();
      toggleElement.checked = true;
      const onChangeEvent = new CustomEvent("change");
      toggleElement.dispatchEvent(onChangeEvent);
      const policyNumber = mockDataPolicies[0].Name;
      const activePolicyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(activePolicyElement.policy.Name).toBe(policyNumber);
      const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
      expect(policyElements).not.toBeNull();
      expect(policyElements).toHaveLength(4);
      policyElements.forEach(policyElement => {
        expect(policyElement.isHousehold).toBe(true);
        expect(policyElement).not.toContain("10-JJ-D128-8")
        expect(policyElement.loggedInSubuser).toEqual('SUBUSERTYPE');
        expect(policyElement.accountList).toEqual([
          {
            "label": "KRISTIN KLANN",
            "value": "001R000001MtmyrIAB",
          }, {
            "label": "OSF HEALTHCARE SYSTEM",
            "value": "001R000001tC542IAC",
          }, {
            "label": "RONALD T THRASHER",
            "value": "001R000001tC544IAC",
          }, {
            "label": "PAUL P KESNER",
            "value": "001R000001tC545IAC",
          }, {
            "label": "DONALD T LONG JR",
            "value": "001R000001tC547IAC",
          }, {
            "label": "DONALD DIVINEY",
            "value": "001R000001tC548IAC",
          }
        ]);
      });
      expect(getAccountIdsForHouseholdFSC).toHaveBeenCalledWith({ recordId: 'HAPPYPATH' });
      const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
      expect(activeSectionElements).not.toBeNull();
      expect(activeSectionElements).toHaveLength(4);
      activeSectionElements.forEach(activeSection => {

        expect(activeSections).toContain(activeSection.name);

      })

      spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
      expect(spinnerElement).toBeFalsy();

      await flushPromises();

      expect(logClickActiveInactiveSlider).toBeCalled();
      expect(logClickCollapseAll).not.toBeCalled();
      expect(logClickExpandAll).not.toBeCalled();
      
    });

  });

  it('handle toggle checked with list view', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-list");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount, false, true);

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const toggleElement = element.shadowRoot.querySelector('[data-id="toggle-status"]');
      expect(toggleElement).not.toBeNull();
      const policyNumber = mockDataPolicies[0].Name;
      const policyElement = element.shadowRoot.querySelector('[data-id="policy-list"]');
      expect(policyElement.policy.Name).toBe(policyNumber);
    })
  });

  it('handle toggle unchecked for inactive policies', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount, true, false);
    let spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
    expect(spinnerElement).toBeTruthy();

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(async () => {
      const toggleElement = element.shadowRoot.querySelector('[data-id="toggle-status"]');
      expect(toggleElement).toBeTruthy();
      toggleElement.checked = false;
      const onChangeEvent = new CustomEvent("change");
      toggleElement.dispatchEvent(onChangeEvent);

      await flushPromises();

      return Promise.resolve().then(async () => {
        const handleExpandElement = element.shadowRoot.querySelector('[data-id="handle-expand"]');
        handleExpandElement.click();
        expect(handleExpandElement).not.toBeNull();
        const policyNumber = mockDataPolicies[2].Name;
        const inactivPolicyElement = element.shadowRoot.querySelector('[data-id="policy"]');
        expect(inactivPolicyElement.policy.Name).toBe(policyNumber);
        const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
        expect(policyElements).not.toBeNull();
        expect(policyElements).toHaveLength(4);
        policyElements.forEach(policyElement => {
          policyElement.isHousehold = true;
          expect(policyElement).not.toContain("131 6408-E20-31")

        });
        const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
        expect(activeSectionElements).not.toBeNull();
        expect(activeSectionElements).toHaveLength(4);
        activeSectionElements.forEach(activeSection => {

          expect(activeSections).toContain(activeSection.name);


        })
        spinnerElement = element.shadowRoot.querySelector('[data-id="loading-spinner"]');
        expect(spinnerElement).toBeFalsy();

      })

    })

  });

  it('handle record id error', async () => {
    fetchAllPolicies.mockRejectedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount, true, false);

    getRecordWireAdapter.error("error");

    await flushPromises();

    return Promise.resolve().then(() => {
      const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(policyElement).toBeNull();
      expect(logException).toBeCalledWith({
        "message": "Error while retrieving account record type: {\"body\":\"error\",\"ok\":false,\"status\":404,\"statusText\":\"NOT_FOUND\"}",
        "method": "policySummaryMain.getRecordData",
      });
      expect(logException).toBeCalledWith({
        "message": "Error retrieving user data: {\"body\":\"error\",\"ok\":false,\"status\":404,\"statusText\":\"NOT_FOUND\"}",
        "method": "policySummaryMain.getUserRecordData",
      });
    })
  });

  it('handle policy processing error with card ', async () => {
    fetchAllPolicies.mockRejectedValue(new Error('POLICY ERROR'))
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

    return Promise.resolve().then(() => {
      const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(policyElement).toBeNull();
      expect(logException).toBeCalledWith({
        "message": "Error retrieving policies data: \"POLICY ERROR\"",
        "method": "policySummaryMain.getPolicies",
      });
    })
  });

  it('handle get policy error', async () => {
    fetchAllPolicies.mockRejectedValue(new Error('POLICY ERROR'));
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

    return Promise.resolve().then(() => {
      const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(policyElement).toBeNull();
      expect(logException).toBeCalledWith({
        "message": "Error retrieving policies data: \"POLICY ERROR\"",
        "method": "policySummaryMain.getPolicies"
      });
    })
  });
  it('handle get household error', async () => {
        fetchAllPolicies.mockResolvedValue(mockDataPolicies);
        fetchUserPreference.mockResolvedValue("policy-card");
        getAccountIdsForHouseholdFSC.mockRejectedValue(new Error('FAILED TO BUILD HOUSEHOLD ACCOUNTS'));
        getGroupPolicyStatus.mockResolvedValue(false);
        getPLMStatus.mockResolvedValue({
          PLM_Opp_Redirect_Active__c: false,
          PLM_Auto_Launch_PC_Active__c: false,
          PLM_Policy_Actions_Active__c: false
        })
        setup('HAPPYPATH', mockAccountNoClient,true,false);
       
        getRecordWireAdapter.emit(mockAccountNoClient);
    
        await flushPromises();

    return Promise.resolve().then(() => {
      expect(logException).toHaveBeenCalledWith({ "message": "Error retrieving Household Data \"FAILED TO BUILD HOUSEHOLD ACCOUNTS\"", "method": "policySummaryMain.loadHouseholdData" });
    })

  });

  it('handle user preference error', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockRejectedValue(new Error('FAILED TO GET USER PREF'));
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount);

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      expect(element.shadowRoot.querySelector('[data-id="policy-list"]')).toBeFalsy();
      const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(policyElement).not.toBeNull();
      expect(logException).toHaveBeenCalledWith({ "message": "Failed to fetch user view preference: \"FAILED TO GET USER PREF\"", "method": "policySummaryMain.getViewPreference" });
    })

  });

  it('handle update view preference', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    updateUserView.mockResolvedValue();
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount, true, false);

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const listViewButtonElement = element.shadowRoot.querySelector('[data-id="list-view-button"]');
      listViewButtonElement.click();

    })
      .then(() => {
        const policyCardElement = element.shadowRoot.querySelector('[data-id="policy-lob"]');
        expect(policyCardElement).toBeFalsy();
        const policyListElement = element.shadowRoot.querySelector('[data-id="policy-list"]');
        expect(policyListElement).toBeTruthy();
        expect(updateUserView).toHaveBeenCalledWith({ userView: 'policy-list' })
        const cardViewButtonElement = element.shadowRoot.querySelector('[data-id="card-view-button"]');
        cardViewButtonElement.click();

      })
      .then(() => {
        const policyCardElement = element.shadowRoot.querySelector('[data-id="policy-lob"]');
        expect(policyCardElement).toBeTruthy();
        const policyListElement = element.shadowRoot.querySelector('[data-id="policy-list"]');
        expect(policyListElement).toBeFalsy();
        expect(updateUserView).toHaveBeenCalledWith({ userView: 'policy-card' })
      })

  });

  it('handle update view preference error', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    updateUserView.mockRejectedValue(new Error('FAILED TO UPDATE USER VIEW'));
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getGroupPolicyStatus.mockResolvedValue(false);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const element = setup('HAPPYPATH', mockAccount, true, false);

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    expect(logException).not.toHaveBeenCalled();

    return Promise.resolve().then(() => {
      const listviewButtonElement = element.shadowRoot.querySelector('[data-id="list-view-button"]');
      listviewButtonElement.click();
    }).then(async () => {
      const policyCardElement = element.shadowRoot.querySelector('[data-id="policy-lob"]');
      expect(policyCardElement).toBeFalsy();
      const policyListElement = element.shadowRoot.querySelector('[data-id="policy-list"]');
      expect(policyListElement).toBeTruthy();

      await flushPromises();

      expect(updateUserView).toHaveBeenCalledWith({ "userView": "policy-list" });
      expect(logException).toHaveBeenCalledWith({ "message": "Failed to update user preference: \"FAILED TO UPDATE USER VIEW\"", "method": "policySummaryMain.updateViewPreference" });
    })

  });

  it('handle no access', async () => {
    getPLMStatus.mockResolvedValue({ PLM_Auto_Launch_PC_Active__c: false, PLM_Opp_Redirect_Active__c: false, PLM_Policy_Actions_Active__c: false })
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    const element = setup('HAPPYPATH', mockAccount, true, false);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const policyNumber = mockDataPolicies[0].Name;
      const policyElement = element.shadowRoot.querySelector('[data-id="policy"]');
      expect(policyElement.policy.Name).toBe(policyNumber);
      expect(policyElement.userAccess.hasPolicyTransactionAccess).toBe(false);
      expect(policyElement.userAccess.hasAutoIdCardAccessforSubuserType).toBe(false);
      expect(policyElement.userAccess.hasAutoIdCardAccessforUserCriteria).toBe(false);
      expect(policyElement.userAccess.hasBOSLinkAccess).toBe(false);
      expect(policyElement.userAccess.hasCOILinkAccess).toBe(false);
      expect(policyElement.plmActivationStatus.isOppRedirectActive).toBe(false);
      expect(policyElement.plmActivationStatus.isPCAutoLaunchActive).toBe(false);
      expect(policyElement.plmActivationStatus.isPolicyActionsActive).toBe(false);

    })

  });

  it('handle getRecordData error', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPolicies);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue(null)
    setup('HAPPYPATH', mockAccount, true, false);

    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      expect(logException).toBeCalledWith({
        "message": "Error while running main promises: \"Cannot read properties of null (reading 'PLM_Opp_Redirect_Active__c')\"",
        "method": "policySummaryMain.getRecordData"
      });
    })
  });

  it('handle empty policy list with card view', async () => {
    fetchAllPolicies.mockResolvedValue([]);
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount, true, false);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    expect(logException).not.toHaveBeenCalled();

    return Promise.resolve().then(() => {
      const activeAccordionsElements = element.shadowRoot.querySelector('lightning-accordion');
      expect(activeAccordionsElements.activeSectionName).toEqual(activeSections);
      const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
      const inactivePolicyElement = element.shadowRoot.querySelector('[key="0YT2C0000008QVqWWW"]');
      expect(inactivePolicyElement).toBeNull();
      expect(activeSectionElements).not.toBeNull();
      expect(activeSectionElements).toHaveLength(0);
      const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
      expect(policyElements).not.toBeNull();
      expect(policyElements).toHaveLength(0);

      const policyListElements = element.shadowRoot.querySelectorAll('[data-id="policy-list"]');
      expect(policyListElements).toHaveLength(0);

      const noPoliciesElement = element.shadowRoot.querySelectorAll('[data-id="no-policies"]');
      expect(noPoliciesElement).toBeTruthy();

      expect(logClickActiveInactiveSlider).not.toBeCalled();
      expect(logClickCollapseAll).not.toBeCalled();
      expect(logClickExpandAll).not.toBeCalled();

      expect(fetchAllPolicies).toHaveBeenCalledWith({ inputRecordId: 'HAPPYPATH', inputRecordTypeId: 'sfdcAccountTypeId' })
    })

  });

  it('handle error on policy fetch with card view', async () => {
    fetchAllPolicies.mockRejectedValue(new Error('policy retrieval error'));
    fetchUserPreference.mockResolvedValue("policy-card");
    getAccountIdsForHouseholdFSC.mockResolvedValue(mockHouseholdData);
    getPLMStatus.mockResolvedValue({
      PLM_Opp_Redirect_Active__c: false,
      PLM_Auto_Launch_PC_Active__c: false,
      PLM_Policy_Actions_Active__c: false
    })
    const activeSections = ['Auto', 'Fire', 'Life', 'Health'];
    const element = setup('HAPPYPATH', mockAccount, true, false);
    getRecordWireAdapter.emit(mockAccount);

    await flushPromises();

    return Promise.resolve().then(() => {
      const activeAccordionsElements = element.shadowRoot.querySelector('lightning-accordion');
      expect(activeAccordionsElements.activeSectionName).toEqual(activeSections);
      const activeSectionElements = element.shadowRoot.querySelectorAll('[data-id="policy-lob"]');
      expect(activeSectionElements).not.toBeNull();
      expect(activeSectionElements).toHaveLength(0);
      const policyElements = element.shadowRoot.querySelectorAll('[data-id="policy"]');
      expect(policyElements).not.toBeNull();
      expect(policyElements).toHaveLength(0);

      const policyListElements = element.shadowRoot.querySelectorAll('[data-id="policy-list"]');
      expect(policyListElements).toHaveLength(0);

      expect(fetchAllPolicies).toHaveBeenCalledWith({ inputRecordId: 'HAPPYPATH', inputRecordTypeId: 'sfdcAccountTypeId' })

      expect(logException).toBeCalledTimes(1);
      expect(logException).toHaveBeenCalledWith({
        "message": "Error retrieving policies data: \"policy retrieval error\"",
        "method": "policySummaryMain.getPolicies",
      });
    })
  });

  it('should log alert found and clicked happy path', async () => {
    fetchAllPolicies.mockResolvedValue(mockDataPoliciesWithAlert);
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

    expect(logSetAlert).toHaveBeenCalled();
    expect(logException).not.toHaveBeenCalled();

    const cardElement = element.shadowRoot.querySelector('[data-id="policy"]')
    cardElement.dispatchEvent(new CustomEvent('alertclick', { detail: { value: 'HAPPYPATH' }, bubbles: true, composed: true }))
    await flushPromises();
    expect(logClickAlert).toHaveBeenCalled();
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

    expect(logException).not.toHaveBeenCalled();

    const children = element.shadowRoot.querySelectorAll("c-policy-summary-card");
    let spies = [];
    children.forEach(child => { spies.push(jest.spyOn(child, 'enhancePolicy')) })

    const enhanceButton = element.shadowRoot.querySelector('[data-id="enhanceAllButton"]');
    expect(enhanceButton.disabled).toEqual(false);
    enhanceButton.click()
    
    await flushPromises();

    expect(enhanceButton.disabled).toEqual(true);
    spies.forEach(spy => { expect(spy).toHaveBeenCalled() })
    expect(logClickEnhanceAll).toHaveBeenCalled();
  });

});