import { LightningElement, api } from 'lwc';
export default class CheckboxGroupForm extends LightningElement {

    @api
    submitButtonText;
    @api
    preSelectedOptions = [];
    @api
    submitEventName;
    @api
    disableCheckboxes;

    checkboxGroupLabelHolder
    @api
    set checkboxGroupLabel(value) {
        this.checkboxGroupLabelHolder = value
    }
    get checkboxGroupLabel() {
        return this.checkboxGroupLabelHolder
    }

    checkboxColumnCountHolder
    @api
    set checkboxColumnCount(value) {
        this.checkboxColumnCountHolder = value;
        this.setColumns()
    }
    get checkboxColumnCount() {
        return this.checkboxColumnCountHolder
    }

    optionsHolder
    @api
    set options(values) {
        values = this.parseIfString(values);
        this.optionsHolder = values
    }
    get options() {
        return this.optionsHolder;
    }

    @api
    clearCheckboxes() {
        this.template.querySelectorAll(`lightning-checkbox-group`).forEach(element => {
            element.value = []
        })
    }

    columns = []
    setColumns() {
        let splitColumns = this.splitArray(this.options, this.checkboxColumnCount)
        for (let i = 0; i < this.checkboxColumnCount; i++) {
            this.columns.push({
                Id: i,
                dataId: `checkboxGroup${i}`,
                name: this.checkboxGroupLabel + i,
                value: this.preSelectedOptions,
                options: splitColumns[i]
            })
        }
    }
    parseIfString(value) {
        if (typeof value === 'string') {
            return JSON.parse(value);
        }
        return value;
    }
    handleSubmit() {
        var totalSelectedOptions = [];
        this.template.querySelectorAll(`lightning-checkbox-group`).forEach(element => {
            totalSelectedOptions = totalSelectedOptions.concat(element.value)
        })
        totalSelectedOptions = [...new Set(totalSelectedOptions)]
        this.dispatchCustomEvent(this.submitEventName, totalSelectedOptions);
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
    splitArray(list, columnCount) {
        let result = []
        let temp = list.slice()
        const split = Math.floor(list.length / columnCount)
        const remainder = Math.ceil(list.length % columnCount)

        for (let i = 0; i < remainder; i++) {
            result.push(temp.splice(0, split + 1))
        }
        while (temp.length > 0) {
            result.push(temp.splice(0, split))
        }
        return result
    }
}