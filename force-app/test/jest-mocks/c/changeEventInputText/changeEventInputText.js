import { api,LightningElement } from 'lwc';

export default class changeEventInputText extends LightningElement {

    @api inputType;
    @api searchBarPlaceholder;
    @api eventName;       
    
       
    handleSubmit(event) {
        let searchBarText = event.target.value;
        
        //If user hit Enter, dispatch the custom event with the applicable search text.
        if(event.key === 'Enter'){ 
            this.dispatchCustomEvent(this.eventName,searchBarText);
        }
    }
    handleReset(event) {
        let searchBarText = event.target.value;
        
        /*If the user resets the search by clicking 'x' or deleting all the characters, dispatch the custom event
        with the 'empty' search text.*/
        if(searchBarText === '' || searchBarText === null) {
            this.dispatchCustomEvent(this.eventName,searchBarText);
        }
    }
    @api
    setInputValue(newValue){
        this.template.querySelector('lightning-input').value=newValue; 
        
    }
    dispatchCustomEvent(evntName, searchBarText) {
        const customEvent = new CustomEvent(evntName, {
            bubbles: false,
            composed: false,
            cancelable: true,
            detail: {
                searchBarText: searchBarText
            }
        });
        
        this.dispatchEvent(customEvent);
    }
}