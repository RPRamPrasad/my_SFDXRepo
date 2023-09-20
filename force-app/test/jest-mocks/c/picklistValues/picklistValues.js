import { LightningElement, api} from 'lwc';
import getPicklistValuesHelper from 'c/picklistValuesHelper';

export default class PicklistValues extends LightningElement {
    
    @api disableCombobox;
    @api valuesToRemove;
    @api objectName;
    @api metaData;
    @api dropdownAlignment='auto';
    @api variant = 'label-hidden'
    @api label;
    @api comboboxOptions;
    fieldNameHolder;
    @api selectedValue;


    @api
    set fieldName(value){
        this.fieldNameHolder = value;
        getPicklistValuesHelper({
            objectName: this.objectName,
            fieldName: value,
            sort: true,
            filterValues: this.valuesToRemove
        }).then(result => {
            this.comboboxOptions = result.filteredPicklistValuesAsOptionList();
        });
    }
    get fieldName(){
        return this.fieldNameHolder;
    }
    
    handleChange(event) {
        var details;
        this.selectedValue = event.detail.value;
        details = {
            selectedValue: this.selectedValue,
            metaData: this.metaData
        }
        this.dispatchCustomEvent('picklistchanged',details);
    }

    get placeHolderData(){
        if (this.selectedValue!==undefined){
            return this.selectedValue;
        }
        return 'Please Select an Option';
    }
    dispatchCustomEvent(eventName, eventDetails) {
        const customEvent = new CustomEvent(eventName, 
            {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: eventDetails
            });
        this.dispatchEvent(customEvent);
    }
}
