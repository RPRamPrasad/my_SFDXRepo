import { LightningElement,api } from 'lwc';

export default class PicklistValues extends LightningElement {
    @api disableCombobox;
    @api valuesToRemove;
    @api objectName;
    @api metaData;
    @api dropdownAlignment='auto';
    @api fieldName;
    @api selectedValue;
    @api variant;
    @api label;
}