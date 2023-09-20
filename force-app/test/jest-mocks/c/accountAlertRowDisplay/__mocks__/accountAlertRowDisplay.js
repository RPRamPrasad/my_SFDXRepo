import { LightningElement, api } from 'lwc';
export default class AccountAlertRowDisplay extends LightningElement {


    @api
    accountId;

    @api
    numberOfRows;

}