import { LightningElement, api } from 'lwc';
export default class SimpleConversationRowDisplay extends LightningElement {
    @api
    accountId;

    @api
    numberOfRows;
}