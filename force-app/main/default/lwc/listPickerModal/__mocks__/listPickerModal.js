import { LightningElement, api } from 'lwc';

export default class listPickerModal extends LightningElement {
    @api title;
    @api list;
    @api pageSize;
}