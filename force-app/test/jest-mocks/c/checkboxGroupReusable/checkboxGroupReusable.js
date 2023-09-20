import { LightningElement, api } from 'lwc';
import 'c/checkBrowser';

export default class CheckboxGroupReusable extends LightningElement {
    @api label;
    @api options = [];
    @api value = [];
    selectAll = false;

    get returnOptions() {
         return this.options;
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    @api selectAllToggle() {
        var allOptions = [];
        this.selectAll = !this.selectAll;
        if(this.selectAll){
            this.options.forEach(element => {
                allOptions.push(element.value);
            }) 
        }
        this.value = allOptions;   
    }
}