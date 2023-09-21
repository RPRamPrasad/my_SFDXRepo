import { getRecord } from 'lightning/uiRecordApi';
import { createElement } from 'lwc';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);

import PolicySummary from 'c/policySummary';
import getPoliciesForRollup from '@salesforce/apex/PolicySummaryController.getPoliciesForRollup';
import getPoliciesForSearch from '@salesforce/apex/PolicySummaryController.getPoliciesForSearch';
import SEARCH_RESULT_COLUMNS from './data/expectedColumns.json';
import SEARCH_RESULT_COLUMNS_NEW from './data/expectedColumnsNew.json';

import mockAccount from './data/mockAccount.json';
import mockDataPolicies from './data/policyTestData.json';

jest.mock(
    '@salesforce/apex/PolicySummaryController.getPoliciesForRollup',
    () => {
        return {
            default: jest.fn()
        }
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/PolicySummaryController.getPoliciesForSearch',
    () => {
        return {
            default: jest.fn()
        }
    },
    { virtual: true }
);


describe('c-policySummary', () => {

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        jest.clearAllMocks();
    });


    // Test Helpers

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    const { setImmediate } = require('timers')
function flushPromises() {
        
        return new Promise(resolve => setImmediate(resolve));
    }

    function setup(recordId, acctRecord, isNewSummary) {
        const element = createElement('c-policySummary', { is: PolicySummary });
        element.recordId = recordId;
        if (isNewSummary) {
            element.isNewSummary = isNewSummary;
        }
        document.body.appendChild(element);

        getRecordWireAdapter.emit(acctRecord);

        return element;
    }

    function assertPolicyCounts(element, expectedValue) {
        const policyCountsElm = element.shadowRoot.querySelector('div.policyCountsData');
        const policyCountsErrorElm = element.shadowRoot.querySelector('div.policyCountsError');

        expect(getPoliciesForRollup).toHaveBeenCalledWith({ recordId: element.recordId, acctRecordTypeId: 'sfdcAccountTypeId' });

        if (element.recordId === "HAPPYPATH") {
            expect(policyCountsElm).not.toBeNull();
            expect(policyCountsElm.textContent).toEqual(expectedValue);

            expect(policyCountsErrorElm).toBeNull();
        }
        else {
            expect(policyCountsElm).toBeNull();

            expect(policyCountsErrorElm).not.toBeNull();
            expect(policyCountsErrorElm.textContent).toEqual(expectedValue);
        }

        return true;
    }


    // Test Suites
    describe('On-Page Load - Policy Sum Totals', () => {

        it('Happy Path - Counts Are Returned', async () => {
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);

            const element = setup('HAPPYPATH', mockAccount);

            return flushPromises()
                .then(() => {
                    expect(element.isNewSummary).toEqual(false);
                    expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.happyPath)).toBeTruthy();
                    const policyCountsElm = element.shadowRoot.querySelector('div.policyCountsData');
                    expect(policyCountsElm).not.toBeNull();
                })
        });

        it('policy counts are not displayed when the new summary is set to true', async () => {
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);

            const element = setup('HAPPYPATH', mockAccount);
            element.isNewSummary = true;

            return flushPromises()
                .then(() => {
                    const policyCountsElm = element.shadowRoot.querySelector('div.policyCountsData');
                    const policyCountsErrorElm = element.shadowRoot.querySelector('div.policyCountsError');
                    expect(policyCountsElm).toBeNull();
                    expect(policyCountsErrorElm).toBeNull();
                })
        });


        it('policy search table is displayed with new summary columns when the new summary is set to true', async () => {

            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);
            getPoliciesForSearch.mockResolvedValue(mockDataPolicies.policiesForSearch);

            const element = setup('HAPPYPATH', mockAccount, true);
            element.isNewSummary = true;

            await flushPromises();

            // Execute
            let searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = '4242 N Capistrano';
            let submitButton = element.shadowRoot.querySelector('.policySearchSubmitBtn');
            submitButton.click();

            await flushPromises();

            // Verify
            expect(getPoliciesForSearch).toBeCalledWith({
                ipSfdcIds: [
                    "0YT2a000000H5gyGAC", "0YT2a000000gxxPGAQ", "salesforceId3", "0YT2a000001ZQs3GAG", "0YT2a000000cLOvGAM", "salesforceId6", "salesforceId7",
                ]
            });

            
            let datatable = element.shadowRoot.querySelector('.policySearchTable');
            expect(datatable).not.toBeNull();

            const cols = datatable.columns;
            expect(cols.length).toEqual(SEARCH_RESULT_COLUMNS_NEW.length);
            for (let i = 0; i < cols.length; i++) {
                expect(cols[i]).toMatchObject(SEARCH_RESULT_COLUMNS_NEW[i]);
            }
        });

        it('Unhappy Path - getPolicies errors for some reason', async () => {
            getPoliciesForRollup.mockRejectedValue('error');

            const element = setup('NOT_HAPPY_PATH', mockAccount);

            return flushPromises()
                .then(() => {
                    expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.error)).toBeTruthy();
                })
        });
    });

    describe('Risk Search', () => {

        it('Complex Happy Path - User can search by Asset Name, results are returned and displayed correctly, then search again with VIN w/o calling SFDC again. Lastly, User uses Clear Search button', async () => {

            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);
            getPoliciesForSearch.mockResolvedValue(mockDataPolicies.policiesForSearch);

            const element = setup('HAPPYPATH', mockAccount);
            element.isNewSummary = false;


            await flushPromises();
            expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.happyPath)).toBeTruthy();

            // Execute
            let searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = '4242 N Capistrano';
            let submitButton = element.shadowRoot.querySelector('.policySearchSubmitBtn');
            submitButton.click();

            await flushPromises();

            // Verify
            expect(getPoliciesForSearch).toBeCalledWith({
                ipSfdcIds: [
                    "0YT2a000000H5gyGAC", "0YT2a000000gxxPGAQ", "salesforceId3", "0YT2a000001ZQs3GAG", "0YT2a000000cLOvGAM", "salesforceId6", "salesforceId7",
                ]
            });

            const policySearchSpinner = element.shadowRoot.querySelector('.policySearchSpinner');
            expect(policySearchSpinner).toBeFalsy();

            let datatable = element.shadowRoot.querySelector('.policySearchTable');

            expect(datatable).not.toBeNull();

            const cols = datatable.columns;
            expect(cols.length).toEqual(SEARCH_RESULT_COLUMNS.length);
            for (let i = 0; i < cols.length; i++) {
                expect(cols[i]).toMatchObject(SEARCH_RESULT_COLUMNS[i]);
            }

            let rows = datatable.data;
            expect(rows.length).toEqual(1);

            let row = rows[0];
            let expectedRow = {
                ModInd: "utility:check",
                Id: "0YT2a000000gxxPGAQ",
                LinkId: "/lightning/r/InsurancePolicy/0YT2a000000gxxPGAQ/view",
                Name: "58-NM-2870-9",
                PolicyName: "Condominium Unitowners Policy",
                MatchingRiskDescriptions: "4242 N Capistrano Unit 141",
                Status: "In Force",
                EffectiveDate: "2000-08-17T12:00:00.000+0000",
                RenewalDate: "2020-08-17T12:00:00.000+0000"
            };
            expect(row.length).toEqual(expectedRow.length);

            for (let key in expectedRow) {
                // eslint-disable-next-line no-prototype-builtins
                if (row.hasOwnProperty(key)) {
                    expect(row[key]).toStrictEqual(expectedRow[key]);
                }
            }

            // Execute Part 2
            searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = '3C6TRVDGXGE546160';
            submitButton = element.shadowRoot.querySelector('.policySearchSubmitBtn');
            submitButton.click();

            await flushPromises();

            // Verify Part 2
            expect(getPoliciesForSearch).toBeCalledTimes(1);
            expect(datatable).not.toBeNull();

            rows = datatable.data;
            expect(rows.length).toEqual(1);

            row = rows[0];
            expectedRow = {
                ModInd: "",
                Id: "0YT2a000000H5gyGAC",
                LinkId: "/lightning/r/InsurancePolicy/0YT2a000000H5gyGAC/view",
                Name: "033 4478-D24-43R",
                PolicyName: "Fleet",
                MatchingRiskDescriptions: "2016 Ram 2500 Crgo Van",
                Status: "In Force",
                EffectiveDate: "1995-10-24T12:00:00.000+0000",
                RenewalDate: "2020-10-24T12:00:00.000+0000"
            };
            expect(row.length).toEqual(expectedRow.length);

            for (let key in expectedRow) {
                // eslint-disable-next-line no-prototype-builtins
                if (row.hasOwnProperty(key)) {
                    expect(row[key]).toStrictEqual(expectedRow[key]);
                }
            }

            // Execute Part 3
            const mockFn = jest.fn();
            searchField.setCustomValidity = mockFn;

            const clearButton = element.shadowRoot.querySelector('.policySearchClearBtn');
            clearButton.click();
            await flushPromises();

            // Verify Part 3
            expect(element.shadowRoot.querySelector('.policySearchTable')).toBeNull();

            expect(searchField.value).toBe('');
            expect(mockFn).toBeCalledTimes(1);
            expect(mockFn).toBeCalledWith('');
        });

        it('No Results Path - User can search, no results are returned and friendly message is displayed instead', async () => {
            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);
            getPoliciesForSearch.mockResolvedValue(mockDataPolicies.policiesForSearch);

            const element = setup('HAPPYPATH', mockAccount);

            await flushPromises();
            expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.happyPath)).toBeTruthy();

            // Execute
            let searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = 'No Results Search';
            let submitButton = element.shadowRoot.querySelector('.policySearchSubmitBtn');
            submitButton.click();

            await flushPromises();

            // Verify
            // No datatable, no errors
            expect(element.shadowRoot.querySelector('.policySearchTable')).toBeNull();
            expect(element.shadowRoot.querySelector('.policySearchError')).toBeNull();

            const noResultsFoundElm = element.shadowRoot.querySelector('.policySearchNoResults');
            expect(noResultsFoundElm).not.toBeNull();
            expect(noResultsFoundElm.textContent).toStrictEqual('No search results to display.');
        });

        it('Bad User Path - User tries bad search (whitespace and < 3 chars), but no results are returned and an error message displayed instead', async () => {

            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);

            const element = setup('HAPPYPATH', mockAccount);
            await flushPromises();

            // Execute
            const searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = '    Ch   ';
            // User hits enter
            searchField.dispatchEvent(new KeyboardEvent('keyup', { 'key': 'Enter' }));

            await flushPromises();

            expect(getPoliciesForSearch).not.toBeCalled();

            // No datatable, no errors, no results text
            
            expect(element.shadowRoot.querySelector('.policySearchTable')).toBeNull();
            expect(element.shadowRoot.querySelector('.policySearchNoResults')).toBeNull();
            expect(element.shadowRoot.querySelector('.policySearchError')).toBeNull();
        });

        it('Error Path - User tries to search, but callout errors and an error message is displayed instead', async () => {

            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);
            getPoliciesForSearch.mockRejectedValue(null);

            const element = setup('HAPPYPATH', mockAccount);

            await flushPromises();
            expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.happyPath)).toBeTruthy();

            // Execute
            let searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = 'src';
            // User hits enter
            searchField.dispatchEvent(new KeyboardEvent('keyup', { 'key': 'Enter' }));

            await flushPromises();

            // Verify
            expect(getPoliciesForSearch).toBeCalledWith({
                ipSfdcIds: [
                    "0YT2a000000H5gyGAC", "0YT2a000000gxxPGAQ", "salesforceId3", "0YT2a000001ZQs3GAG", "0YT2a000000cLOvGAM", "salesforceId6", "salesforceId7",
                ]
            });

            // No datatable, or results text
            expect(element.shadowRoot.querySelector('.policySearchTable')).toBeNull();
            expect(element.shadowRoot.querySelector('.policySearchNoResults')).toBeNull();

            // Error message to user
            const errorElm = element.shadowRoot.querySelector('.policySearchError');
            expect(errorElm).not.toBeNull();
            expect(errorElm.textContent).toStrictEqual('Something went wrong; please try your search again. If this continues, please contact your normal support channel.');
        });

        it("Doesn't Submit Early Path - Searching doesn't take place when Enter or 'Search' aren't clicked", async () => {
            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);

            const element = setup('HAPPYPATH', mockAccount);
            await flushPromises();

            // Execute
            const searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = 'Malibu';
            // User hits enter
            searchField.dispatchEvent(new KeyboardEvent('keyup', { 'key': 'r' }));

            await flushPromises();

            expect(getPoliciesForSearch).not.toBeCalled();
        });
    });


    describe('Misc Tests', () => {

        it('LWC has the right initial vars/elements', () => {
            getPoliciesForRollup.mockResolvedValue(null);

            const element = setup('INIT_ID');

            return flushPromises()
                .then(() => {

                    // .policySearchSpinner
                    // - should be null
                    let policySearchSpinner = element.shadowRoot.querySelector('.policySearchSpinner');
                    expect(policySearchSpinner).toBeFalsy();
                    // .policySearchTable
                    // - should be null
                    let policySearchTable = element.shadowRoot.querySelector('.policySearchTable');
                    expect(policySearchTable).toBeFalsy();

                    // .policySearchNoResults
                    // - should be null
                    let policySearchNoResults = element.shadowRoot.querySelector('.policySearchNoResults');
                    expect(policySearchNoResults).toBeFalsy();

                    // .policySearchError
                    // - should be null
                    let policySearchError = element.shadowRoot.querySelector('.policySearchError');
                    expect(policySearchError).toBeFalsy();

                    // .policyCountsData
                    // - should be NOT null, should be 'Products (...)'
                    let policyCountsData = element.shadowRoot.querySelector('.policyCountsData');
                    expect(policyCountsData).toBeTruthy();
                    expect(policyCountsData.textContent).toStrictEqual('Products (...)');

                    // .policyCountsError
                    // - should be null
                    let policyCountsError = element.shadowRoot.querySelector('.policyCountsError');
                    expect(policyCountsError).toBeFalsy();
                });
        });

        it('Mod Indicator Tests', async () => {
            // Prep
            getPoliciesForRollup.mockResolvedValue(mockDataPolicies.policies);
            const policies = mockDataPolicies.policiesForLegacyVsMod;
            getPoliciesForSearch.mockResolvedValue(policies);

            const element = setup('HAPPYPATH', mockAccount);

            await flushPromises();
            expect(assertPolicyCounts(element, mockDataPolicies.rollupTexts.happyPath)).toBeTruthy();

            // Execute
            const searchField = element.shadowRoot.querySelector('.policySearchField');
            searchField.value = 'All';
            const submitButton = element.shadowRoot.querySelector('.policySearchSubmitBtn');
            submitButton.click();

            await flushPromises();

            // Verify

            const policySearchSpinner = element.shadowRoot.querySelector('.policySearchSpinner');
            expect(policySearchSpinner).toBeFalsy();

            const datatable = element.shadowRoot.querySelector('.policySearchTable');

            expect(datatable).not.toBeNull();

            const rows = datatable.data;
            expect(rows.length).toEqual(5);

            const expectedMod = [false, false, false, false, true];

            for (let idx = 0; idx < datatable.data.length; idx++) {
                const row = datatable.data[idx];

                if (expectedMod[idx]) {
                    expect(row.ModInd).toEqual('utility:check');
                }
                else {
                    expect(row.ModInd).toBeFalsy();
                }
            }
        });
    });
});