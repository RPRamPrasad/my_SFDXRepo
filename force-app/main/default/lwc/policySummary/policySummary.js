// SFDC imports
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { api, LightningElement, wire } from "lwc";
import ACCT_RECORD_TYPE_ID from '@salesforce/schema/Account.RecordTypeId';

import { SEARCH_RESULT_COLUMNS, SEARCH_RESULT_COLUMNS_NEW } from "./columns";
import { buildSumTotals, buildTable } from './policySummaryHelper';

// My Apex class imports
import getPoliciesForRollup from '@salesforce/apex/PolicySummaryController.getPoliciesForRollup';
import getPoliciesForSearch from '@salesforce/apex/PolicySummaryController.getPoliciesForSearch';

export default class PolicySummary extends LightningElement {

    @api isNewSummary = false;
    @api recordId;

    acctRecordTypeId;
    isSearching = false;
    policies;
    policySumTotals = {
        data: "Products (...)"
    };
    rollupPolicies;
    searchError = false;
    searchResults = null;
    searchResultColumns;


    @wire(getRecord, { recordId: '$recordId', fields: [ACCT_RECORD_TYPE_ID] })
    async getRecordData(result) {
        this.searchResultColumns = this.isNewSummary ? SEARCH_RESULT_COLUMNS_NEW : SEARCH_RESULT_COLUMNS;
        
        if (result.data) {
            this.acctRecordTypeId = getFieldValue(result.data, ACCT_RECORD_TYPE_ID);

            // Get policies
            try {
                this.rollupPolicies = await getPoliciesForRollup({ recordId: this.recordId, acctRecordTypeId: this.acctRecordTypeId });
    
                this.policySumTotals = buildSumTotals(this.rollupPolicies);
            }
            catch (e) {
                this.policySumTotals = {
                    error: true
                };
            }
        }
    }

    onClickClearSearch() {
        this.searchResults = null;
        this.searchCriteria = '';

        const searchField = this.template.querySelector('.policySearchField');
        searchField.value = this.searchCriteria;
        searchField.setCustomValidity('');
        searchField.reportValidity();
    }

    onClickSearchButton() {
        const searchField = this.template.querySelector('.policySearchField');
        this.executeSearch(searchField.value, searchField);
    }

    onKeyUpSearch(evt) {
        const isEnterKey = evt.key === 'Enter';

        if (isEnterKey) {
            this.executeSearch(evt.target.value, evt.target);
        }
    }

    async executeSearch(userInput, searchField) {

        const searchCriteria = userInput.trim();

        let validationMsg = '';
        if (searchCriteria.length < 3) {
            validationMsg = 'Please enter 3 or more characters to search.';
            searchField.value = searchCriteria;
        }

        searchField.setCustomValidity(validationMsg);
        searchField.reportValidity();

        if (!validationMsg.length) {
            this.isSearching = true;

            // If first execution, then grab all Insurance Policies and their Assets, leveraging the previous callout's IP.ids
            if (!this.policies) {
                try {
                    // Get ids
                    const ipSfdcIds = this.rollupPolicies.map(policy => policy.Id);

                    // Pass to Apex method to get IPs + IPs and return payload
                    this.policies = await getPoliciesForSearch({ ipSfdcIds });
                }
                catch (e) {
                    this.searchResults = null;
                    this.searchError = true;

                    this.isSearching = false;
                    return;
                }
            }

            // Next, execute search over the IP + IPA data and build table
            this.searchResults = buildTable(this.policies, searchCriteria);

            this.isSearching = false;
            this.searchError = false;
        }
    }
}