import { LightningElement, api } from 'lwc';
import { buildToofDate, buildToofSource, buildAppDate } from './buildToofData';

export default class PolicyDetailsToofReinstatement extends LightningElement {
    @api details;
    @api lob;

    toofDates;
    toofSource;
    reinstatementAppdate;

    get toofDatesExist() {
        return this.toofDates?.length;
    }

    get showToofSection() {
        return this.toofDates?.length || this.toofSource || this.reinstatementAppDate;
    }

    async connectedCallback() {
        await this.buildToofReinstatement(this.details);
    }

    async buildToofReinstatement(policy) {

        this.toofDates = buildToofDate(policy);
        this.toofSource = buildToofSource(policy);
        this.reinstatementAppdate = buildAppDate(policy);

    }
}