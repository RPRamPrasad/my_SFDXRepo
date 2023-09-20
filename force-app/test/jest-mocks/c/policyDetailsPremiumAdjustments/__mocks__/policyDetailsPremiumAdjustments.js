import { LightningElement, api } from 'lwc';

export default class PolicyDetailsPremiumAdjustments extends LightningElement {
    @api details;
    @api lob;
    @api hasFullAccess;
}