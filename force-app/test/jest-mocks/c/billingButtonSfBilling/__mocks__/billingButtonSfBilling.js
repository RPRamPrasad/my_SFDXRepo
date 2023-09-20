import { LightningElement, api } from 'lwc';

export default class BillingButtonSfBilling extends LightningElement {
    @api billingAccountNumber;
    @api billingAccountUrl;
    @api billingAccountUrlDescription;
}