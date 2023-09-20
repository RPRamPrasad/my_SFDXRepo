import { LightningElement, api } from 'lwc';
import { constants } from 'c/policyDetailsCommonJS';

const {
    AUTO,
    FIRE
} = constants;

export default class PolicyDetailsRating extends LightningElement {
    @api details;
    @api hasFullAccess = false;
    @api lob;

    auto = false;
    fire = false;

    connectedCallback() {
        if (this.lob === AUTO) {
            this.auto = true;
        } else if (this.lob === FIRE) {
            this.fire = true;
        }
    }
}