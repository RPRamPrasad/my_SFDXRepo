import { LightningElement, api } from 'lwc';

export default class AssignToInput extends LightningElement {

    @api inputId;
    @api inputMax;
    @api inputPlaceHolder = "Enter Number of Records";
    @api numberOfRecordsToAssign = 0;
    
    get inputErrorMessage() {
      return `Between 0 - ${this.inputMax}`;
    }

    handleNumberEntry(event) {
      this.dispatchCustomEvent("usernumberentry", { assignToInputId: this.inputId, 
                                                    newValue: event.target.value, 
                                                    isValid: event.target.validity.valid });
    }

    dispatchCustomEvent(eventName, eventDetails) {
      const customEvent = new CustomEvent(eventName, 
          {
              composed: false,
              bubbles: false,
              cancelable: false,
              detail: eventDetails
          });
      this.dispatchEvent(customEvent);
    }
}