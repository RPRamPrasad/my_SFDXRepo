import { LightningElement, api } from 'lwc';

export default class BillingButtonSfpp extends LightningElement {
    @api billingAccountNumber;
    @api stateAgentCode;
    @api status;
}