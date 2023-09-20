import { api, LightningElement } from 'lwc';

export default class BillingLobInfoHover extends LightningElement {

    @api displayValue;
    @api displayType;
    @api hoverText;

    get isCurrency(){
        return this.displayType === 'currency';
    }
}