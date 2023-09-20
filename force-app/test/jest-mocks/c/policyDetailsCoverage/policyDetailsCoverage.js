import { LightningElement, api } from 'lwc';
import { buildAutoCoverages } from './buildAutoCoverages';
import { buildFireCoverages } from './buildFireCoverages';
import { constants } from 'c/policyDetailsCommonJS';
import { FIRE_FULL_VIEW_COLUMNS, FIRE_SIMPLE_VIEW_COLUMNS, AUTO_FULL_VIEW_COLUMNS, AUTO_SIMPLE_VIEW_COLUMNS } from './columns';

const { AUTO, FIRE } = constants;

export default class PolicyDetailsCoverage extends LightningElement {

    @api details;
    @api lob;
    @api hasFullAccess;

    coverages = [];
    coveragesDisplayed = [];
    coverageAbbreviations = [];
    coverageColumns;
    totalPremium;

    auto = false;
    fire = false;

    get showTotalPremium() {
        let showTotalPremium = false;

        if (this.totalPremium && this.hasFullAccess) {
            showTotalPremium = true;
        }

        return showTotalPremium;
    }

    connectedCallback() {
        this.buildCoveragesData();
        this.coveragesDisplayed = this.coverages;
    }

    buildCoveragesData() {
        const details = this.details;

        let riskCoverages = [];
        let policyCoverages = [];

        if (details.termVersion?.insurableRisk?.length && details.termVersion.insurableRisk[0].coverageSet?.coverage) {
            riskCoverages = details.termVersion.insurableRisk[0].coverageSet.coverage;
        }

        if (details.termVersion?.policyCoverageSet?.coverage) {
            policyCoverages = details.termVersion.policyCoverageSet.coverage;
        }

        if (this.lob === AUTO) {
            this.auto = true;
            if (this.hasFullAccess) {
                this.coverageColumns = AUTO_FULL_VIEW_COLUMNS;
            } else {
                this.coverageColumns = AUTO_SIMPLE_VIEW_COLUMNS;
            }

            const { coverageText, formattedCoverages, totalPremium } = buildAutoCoverages(riskCoverages);

            this.coverages = this.sortCoverages(formattedCoverages);
            this.coverageAbbreviations = this.sortAbbreviations(coverageText);
            this.totalPremium = '$' + totalPremium.toString();

        } else if (this.lob === FIRE) {
            this.fire = true;
            if (this.hasFullAccess) {
                this.coverageColumns = FIRE_FULL_VIEW_COLUMNS;
            } else {
                this.coverageColumns = FIRE_SIMPLE_VIEW_COLUMNS;
            }
            const combinedCoverages = [...riskCoverages, ...policyCoverages];
            this.coverages = buildFireCoverages(combinedCoverages);
        }
    }

    sortCoverages(formattedCoverages) {
        return formattedCoverages.sort((a, b) => {
            if (a.abbreviation < b.abbreviation) { return -1; }
            if (a.abbreviation > b.abbreviation) { return 1; }
            return 0;
        });
    }
    sortAbbreviations(coverageText) {
        return coverageText.split(", ").sort((a, b) => {
            if (a[0] < b[0]) { return -1; }
            if (a[0] > b[0]) { return 1; }
            return 0;
        });
    }
}

export { buildAutoCoverages }