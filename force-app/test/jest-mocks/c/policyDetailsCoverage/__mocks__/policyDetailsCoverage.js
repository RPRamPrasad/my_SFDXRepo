import { LightningElement, api } from 'lwc';

export default class PolicyDetailsCoverage extends LightningElement {
    @api details;
    @api lob;
    @api hasFullAccess;
}