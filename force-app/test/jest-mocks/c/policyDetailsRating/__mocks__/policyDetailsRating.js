import { LightningElement, api } from 'lwc';

export default class PolicyDetailsRating extends LightningElement {
    @api details;
    @api lob;
    @api hasFullAccess;
}