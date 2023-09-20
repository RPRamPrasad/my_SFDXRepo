import { LightningElement,api } from 'lwc';
const SOBJECT_LINK_URL = '/one/one.app#/sObject/';
export default class SObjectRowDisplayRow extends LightningElement {
 
    @api
    label
    @api
    value

    link;
    displayLink = false;

    @api
    get sobjectid(){
        return this.sobjectIdHolder;
    }
    set sobjectid(value){
        if(value !== undefined){
            this.sobjectIdHolder = value;
            this.link = SOBJECT_LINK_URL + value;
            this.displayLink = true;
        }
    }

}