import { LightningElement,api } from 'lwc';
export default class SObjectRowDisplayRow extends LightningElement {

    @api
    label
    @api
    value
    @api
    sobjectid
}