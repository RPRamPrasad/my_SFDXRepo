import { LightningElement, api } from 'lwc';

export default class PolicyDetailsVehicle extends LightningElement {
    @api details;
    @api lob;
    @api hasFullAccess;
}