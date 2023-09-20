import { LightningElement, api } from 'lwc';
import { constants } from 'c/policyDetailsCommonJS';
const { MULTI_VEHICLE, LEGACY_CD } = constants;
export default class PolicySummaryRiskHover extends LightningElement {
    @api risks;
    @api policy;

    showHover = false; 

    get isMultiCarAuto() {
        return parseInt(this.policy.AgreSourceSysCd__c, 10) === LEGACY_CD && this.policy.PolicyDescription?.toUpperCase().includes(MULTI_VEHICLE);
    }

    handleHoverOpen() {
        this.showHover = true;
    }

    handleHoverClose() {
        this.showHover = false;
    }
}