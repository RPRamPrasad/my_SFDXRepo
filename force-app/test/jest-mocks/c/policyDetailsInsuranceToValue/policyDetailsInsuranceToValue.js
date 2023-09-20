import { LightningElement, api } from 'lwc';

const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export default class PolicyDetailsInsuranceToValue extends LightningElement {
    @api details;
    @api regionCode;
    @api userAlias;

    dateOfEstimate = 'N/A';
    replacementCost = 'N/A';
    insuranceToValueRate = 'N/A';
    currentCoverage = 'N/A';
    estimateNumber = 'N/A';
    xactwareUrl;
    regionStateAgentCode;

    connectedCallback() {
        this.buildInsuranceToValue(this.details);
    }

    buildInsuranceToValue(policy) {
        if (policy?.termVersion?.insurableRisk?.length) {
            let insurableRisk = policy.termVersion.insurableRisk[0];
            this.regionStateAgentCode = this.buildRegionStateAgentCode(policy);

            if (insurableRisk?.building?.length) {
                let building = insurableRisk.building[0];

                this.buildFieldsFromBuilding(building);
            }

            if (policy?.termVersion?.policyCoverageSet?.coverage) {
                let coverages = policy.termVersion.policyCoverageSet.coverage;
                let dwellingCov = coverages.find(cov => cov.abbreviation === 'A');
                let covAmount = dwellingCov?.coverageProperty.find(prop => prop.name === 'Limit Per Occurrence')?.valueNum;

                this.currentCoverage = covAmount ? formatter.format(covAmount) : 'N/A';
            }
        }
    }

    buildRegionStateAgentCode(policy) {
        if (policy.agentOfRecord && policy.agentOfRecord.stateCode && policy.agentOfRecord.agentCode) {
            let stateCode = policy.agentOfRecord.stateCode;
            let agentCode = policy.agentOfRecord.agentCode;
            return `${this.regionCode + stateCode + agentCode}`;
        }
        return null;
    }

    buildFieldsFromBuilding(building) {
        this.replacementCost = building.replacementCostEstimateAmount ? formatter.format(building.replacementCostEstimateAmount) : 'N/A';
        this.insuranceToValueRate = building.insuranceToValueCode ? `${building.insuranceToValueCode}%` : 'N/A';

        if (building?.inspection?.length) {
            let inspection = building.inspection[0];

            this.dateOfEstimate = inspection.inspectionCompletionDate ? this.buildDate(inspection.inspectionCompletionDate) : 'N/A';
            this.estimateNumber = inspection.inspectionIdentificationNumber || 'N/A';
            this.xactwareUrl = this.buildXactwareUrl();
        }
    }

    buildXactwareUrl() {
        return this.estimateNumber !== 'N/A' ? `/apex/VFP_ExternalLink?LinkId=249&EstNum=${this.estimateNumber}&ABSActiveAgent=${this.regionStateAgentCode}&absuserid=${this.userAlias}` : null;
    }

    buildDate(dateInput) {
        let date = new Date(dateInput);

        return `${date.getMonth() + 1}-${date.getDate() + 1}-${date.getFullYear()}`;
    }
}