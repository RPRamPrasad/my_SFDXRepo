import { api,LightningElement } from 'lwc';

export default class changeEventInputText extends LightningElement {

    @api inputType;
    @api searchBarPlaceholder;
    @api eventName;       
    
    @api
    setInputValue = jest.fn();
    
}