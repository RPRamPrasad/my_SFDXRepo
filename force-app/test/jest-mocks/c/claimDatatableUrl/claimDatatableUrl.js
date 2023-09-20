import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api } from 'lwc';

export default class ClaimDatatableUrl extends NavigationMixin(LightningElement) {

    @api label;
    @api url;

    get isClassicClaim() {
        return this.url.includes('/apex/VFP_ExternalLink');
    }
}