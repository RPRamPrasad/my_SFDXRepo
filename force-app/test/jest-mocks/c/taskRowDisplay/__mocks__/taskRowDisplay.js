import { LightningElement, api } from 'lwc';
export default class TaskRowDisplay extends LightningElement {


    @api
    accountId;

    @api
    numberOfRows;

}