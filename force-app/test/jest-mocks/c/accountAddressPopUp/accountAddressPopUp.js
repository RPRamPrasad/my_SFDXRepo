import { LightningElement, track, api } from 'lwc';
export default class AccountAddressPopup extends LightningElement {
    @api addressType;
    @api standardAddress;
    @api currentAddress;

    @track is04; // = false; // initialized in connectedCallback
    @track is06; // = false; // initialized in connectedCallback
    @track currentAddrString;
    @track standardAddrString;
    @track accountReturn;
    @track errorsHeld;
    @track testLabel;
    @track errorDisplay = [];

    connectedCallback() {
        this.currentAddrString = this.currentAddress.streets;
        if (this.standardAddress[0] === '04') {
            this.standardAddrString = this.standardAddress[1].standardizedAddress.streets + '\n' + this.standardAddress[1].standardizedAddress.city + ', '
             + this.standardAddress[1].standardizedAddress.stateProvince + ' ' + this.standardAddress[1].standardizedAddress.postalCode;
            this.is04 = true;
            this.is06 = false;
            this.testLabel = '04';
            this.accountReturn = { value: 'standard', data: this.standardAddress[1] };
        } else {
            this.is06 = true;
            this.is04 = false;
            this.testLabel = '06';
        }
        this.errorsHeld = this.standardAddress[1].messages;
        if (!Array.isArray(this.errorsHeld)) {
            this.errorDisplay[0] = this.errorsHeld;
        } else {
            for (let i = 0; i < this.errorsHeld.length; i++) {
                this.errorDisplay[i] = this.errorsHeld[i];
            }
        }
    }

    renderedCallback(){
        if (this.standardAddress[0] === '04') {
        this.bringFocusOnPopUP("standard");}
        else{
            this.bringFocusOnPopUP("Edit");
        }
    }

    bringFocusOnPopUP(dataId){
        this.template.querySelector('[data-id="'+dataId+'"]').focus();
    }

    handleChange(event) {
        let returned = event.target.value;
        if (returned === 'standard') { this.accountReturn = { value: returned, data: this.standardAddress[1] }; }
        else { this.accountReturn = { value: returned, data: null }; }
    }

    closeAddStd(event) {
        event.preventDefault();
        let  detailVal = { return: 'edit', addressType: this.addressType };
        if (event.target.value === 'save') { 
            if (!this.is06) { detailVal = { return: this.accountReturn, addType: this.addressType }; }
            else { detailVal = { return: { value: 'current', data: 'is06' }, addType: this.addressType }; }
        }
        const close = new CustomEvent("close", { detail: detailVal });
        this.dispatchEvent(close);
    }
    
    editFocus(){ this.template.querySelector('[data-id="Continue"]').focus(); }

    notStandFocus(){ this.template.querySelector('[data-id="Edit"]').focus(); }

    standardFocus(){ this.template.querySelector('[data-id="notStandard"]').focus(); }

    continueFocus(){ 
        if(this.is04 === true){ 
            this.template.querySelector('[data-id="standard"]').focus();
        } else { this.notStandFocus(); }
    }
}
