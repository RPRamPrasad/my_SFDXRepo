/* eslint-disable no-console */
import { LightningElement,api,wire,track } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { publish, MessageContext } from 'lightning/messageService';
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import {buildMessage} from 'c/messageServiceHelper';
import {events, campaignMessage} from 'c/campaignConstants';
const SUCCESS_MESSAGE = "Case created successfully";

export default class CaseCreateEdit extends NavigationMixin(LightningElement) {
    @api objectApiName='Case';
    @api campaignId;
    @api accountId;
    @api contactId;
    @api campMembId;
    @track caseOwner=Id;
    @track enableSpinner;
     @api userFullName;
    displayError;
    displayErrorMsg;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {recordId:Id, fields: ['User.Name']})
    userData({data}) {
        if(data){
            this.userFullName = data.fields.Name.value;
        }
    }

    connectedCallback(){
        this.enableSpinner=true;
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    handleOnLoad(){
        this.enableSpinner = false;
    }
    handleCancel() {
        this.dispatchEvent(buildCancelEvent());
    }
    
    handleSubmit(event){
        this.enableSpinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.CampaignId__c=this.campaignId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    
    handleSuccess(event) {
        this.enableSpinner = false;
        this.handleCancel();
        this.handleSuccessEventToCampaignMember();
        this.showToastEvent("", SUCCESS_MESSAGE, 'success');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
    handleSuccessEventToCampaignMember() {
        publish(this.messageContext, campaignMessage, buildMessage(events.NEW_CASE_CREATE_SUCCESS,
            this.campMembId));
    }
    handleError(event) {
        var fieldError = JSON.stringify(event.detail.output.fieldErrors);
        const empty = '{}';
        this.enableSpinner = false;
        if(fieldError === empty) {
            this.displayError = true;
            this.displayErrorMsg = event.detail.detail;
        }
    }
    showToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}

function buildCancelEvent() {
    return new CustomEvent('cancel');
}