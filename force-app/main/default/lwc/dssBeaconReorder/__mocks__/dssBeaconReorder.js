import { LightningElement, api } from 'lwc';

export default class DssBeaconReorder extends LightningElement {
    @api customerStreet;
    @api customerCity;
    @api customerState;
    @api customerZip;
    @api customerClientId;
    @api customerFirstName;
    @api customerLastName;
    @api accountName;
    @api policyNumber;
    @api productDescription;
    @api sourceSystemCode;

    @api toggleModal() {}
}
