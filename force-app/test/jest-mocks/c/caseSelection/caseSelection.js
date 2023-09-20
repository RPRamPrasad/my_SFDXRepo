import { LightningElement, api, wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_REASON_FIELD from '@salesforce/schema/Case.Reason';
import { MessageContext } from 'lightning/messageService';

export default class CaseSelection extends NavigationMixin(LightningElement) {
    @api header;
    @api showCaseReason = false;
    @api showPolicy = false;
    @api noPolicyError = false;
    @api showSaveButton = false;
    @api value="servicerequest";
    
    @api logTitleValue;
    @api campaignId;
    @api recordId;
    @api accountId;
    @api contactId;
    @api campMembId;
    @api policyDetails;
    @api policyDataOptions;
    @track selectedPolicyValue;
    @track selectedCaseReasonValue;
    
    @wire(MessageContext)
    messageContext;

    // object info using wire service
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CASE_REASON_FIELD})
    CaseReasonPicklistValues;
    
    get options() {
        return [
            { label: 'Customer Service Request Policy/Billing Service Request', value: 'servicerequest' },
            { label: 'Policy Change', value: 'policychange' }
        ];
    }

     policyOptions(){
        var policy;
        var policytemp;
        var value;
        try {
            value = JSON.parse(this.policyDetails); 
            policytemp = value.policyData; 
            this.policyDataOptions = [];
            for (policy of policytemp){ 
                if (policy.lob !== undefined && policy.policyNumber !== undefined && policy.description !== undefined){
                    this.policyDataOptions.push({ label: policy.lob + ' - ' + policy.policyNumber + ' - ' + policy.description ,value: policy.policyNumber});
                }
            }
        } catch (error) {
            this.policyDataOptions = undefined;
        }
    }

    handleRecordTypeChange(event) {
        const selectedOption = event.detail.value;
        var displayError;
        if(this.policyDetails!==undefined){
            this.policyOptions();
            
        }
        if(selectedOption==='policychange'){
            displayError = this.showErrorMessage();
            if (displayError){
                this.noPolicyError = true; 
                this.hidePolicy();
                this.showSaveButton = true;
            }else{
            this.showPolicyDetails();
            this.noPolicyError = false;
        }
        }else{
            this.hidePolicy();
            this.noPolicyError = false;
        }
    }

     showErrorMessage(){
        if(this.policyDetails===undefined){
            return true;
        }else if(this.policyDataOptions===undefined || this.policyDataOptions.length===0){
            return true;
        }
        return false;
    }

    hidePolicy(){
        this.showPolicy = false;
        this.showCaseReason = false;
        this.showSaveButton = false;
    }

    showPolicyDetails(){
        this.showPolicy = true;
        this.showCaseReason = true;
        this.showSaveButton = true;
    }
    
    handleCancel() {
        this.dispatchEvent(buildCancelEvent());
    }
    
    handleNext() {
        this.dispatchEvent(buildNextEvent());
    }
}
function buildCancelEvent() {
    return new CustomEvent('cancel');
}
function buildNextEvent() {
    return new CustomEvent('next');
}