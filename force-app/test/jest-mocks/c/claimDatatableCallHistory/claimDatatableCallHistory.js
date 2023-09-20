import { LightningElement, api } from 'lwc';

export default class ClaimDatatableCallHistory extends LightningElement {

    @api description;

    @api type;
    @api participants;
    @api handler;

    get isCallHistory() {
        if (this.description) {
            return false;
        }
        return true;
    }
}