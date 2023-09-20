import { LightningElement,track,api } from 'lwc';
import ppoPopup from '@salesforce/label/c.CL_Customer_PPO_READ';

export default class AccountPPOPopup extends LightningElement {
    @api isCCCUser;
    @api get isDonotSharechecked(){ return this.isDonotSharecheck; }
    set isDonotSharechecked(value){ this.isDonotSharecheck = value; }

    @track doNotShare;
    @track isDonotSharecheck;
    
    isPPO;
    label = { ppoPopup };
    
    handlePPO(evt){
        this.isPPO = false;
        if(evt.target.title === 'Yes'){ this.isPPO = true; }
        this.sendDataToSave();
    }

    renderedCallback(){       
        if (this.isDonotSharecheck === true) {this.bringFocusOnPopUP("dnscheck");}
        else{
            try{this.bringFocusOnPopUP("DoNotShare");}
            // eslint-disable-next-line no-empty
            catch(e){}
        }
    }

    bringFocusOnPopUP(dataId){
        this.template.querySelector(`[data-id="`+dataId+`"]`).focus();
    }
    
    handledoNotShare(evt){
        this.isDonotSharecheck = evt.target.checked;
        this.doNotShare = evt.target.checked;
    }

    handleclose(){
        const selectedEvent = new CustomEvent('modalclose', { detail: 'edit'});
        this.dispatchEvent(selectedEvent);
    }

    sendDataToSave(){
        let ppoJson = {};
        ppoJson.IsNotShareable__c = this.doNotShare;
        ppoJson.IsPrivacyOptionsShared__c = this.isPPO;
        const selectedEvent = new CustomEvent('modalclose', { detail: ppoJson});
        this.dispatchEvent(selectedEvent);
    }
    agreeFocus(){
        this.template.querySelector(`[data-id="Yes"]`).focus();
    }

    disAgreeFocus(){
        this.template.querySelector(`[data-id="close"]`).focus();
    }
    closeFocus(){
        if (this.isDonotSharecheck === true) {
            this.template.querySelector(`[data-id="dnscheck"]`).focus();
        }
        else{
            this.bringFocusOnPopUP("DoNotShare");
            this.template.querySelector(`[data-id="DoNotShare"]`).focus();
        }
    }
}
