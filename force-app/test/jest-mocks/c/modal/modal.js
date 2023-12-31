import { LightningElement, api, track } from 'lwc';

const CSS_CLASS = 'modal-hidden';

export default class Modal extends LightningElement {
    @api
    showModal = false;
    widthStyle="";
    @api backdropModal = false;
    scrollValue="";

    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    @api
    get header() {
        return this._headerPrivate;
    }
    
    set modalWidth(value){
        this.widthStyle = "max-width:" + value + "%; width:"+value + "%;";
    }
    @api 
    get modalWidth(){
        return this.widthStyle;
    }
    set modalScroll(value){
        this.scrollValue = "overflow-y:"+ value+ "!important;";
    }
    @api 
    get modalScroll(){
        return this.scrollValue;
    }
    @track hasHeaderString = false;
    _headerPrivate;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }
}