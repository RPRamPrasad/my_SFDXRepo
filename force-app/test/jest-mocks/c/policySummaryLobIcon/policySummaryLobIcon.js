import { LightningElement, api } from 'lwc';
import policyLogos from '@salesforce/resourceUrl/policySummaryLogos'

export default class PolicySummaryLobIcon extends LightningElement {
    @api lob;
    @api sourceCode;

    iconPath;

    connectedCallback() {
        if (this.lob) {
            this.iconPath = `${policyLogos}/${this.lob?.toLowerCase()}.svg`;
        }
    }

    get isMod() {
        const code = this.sourceCode;
        if (!code || code === '1' || code === '3' || code === '7' || code === '8' || code === '28') {
            return false;
        }
        return true;
    }
}