import { LightningElement, api } from 'lwc';

export default class AssignToInput extends LightningElement {
     
    @api inputId;
    @api selectedUser;
    letterEntryError = false;
    errorMessage;
    
    get nameLabel() {
        if (this.selectedUser) {
            return this.selectedUser.Name;
        }
        return '';
    }
 
    handleLetterEntry(event) {
      this.errorMessage = event.detail.message;
      const eventLetters = Object.values(event.detail.selection);
           
      if(this.errorMessage) {
        this.letterEntryError = true;
      } else {
          this.letterEntryError = false;
          this.dispatchCustomEvent("lettersentered", { assignToInputId: this.inputId, letters: eventLetters } );
      }
      event.stopPropagation();
    }

    removeRow() {
        this.dispatchCustomEvent("removerow", { assignToInputId: this.inputId, selectedUserId: this.selectedUser.Id });
    }

    @api
    changeGridDimensions(assignMethod){
      if( assignMethod === 'number' ) {
        const nameDiv = this.template.querySelector('[data-id="name-div"]');
        nameDiv.classList.remove('slds-size_6-of-12');
        nameDiv.classList.add('slds-size_8-of-12');
        
        const slotDiv = this.template.querySelector('[data-id="slot-div"]');
        slotDiv.classList.remove('slds-size_5-of-12');
        slotDiv.classList.add('slds-size_3-of-12');
        
      } else {
          const nameDiv = this.template.querySelector('[data-id="name-div"]');
          nameDiv.classList.remove('slds-size_8-of-12');
          nameDiv.classList.add('slds-size_6-of-12');
          
          const slotDiv = this.template.querySelector('[data-id="slot-div"]');
          slotDiv.classList.remove('slds-size_3-of-12');
          slotDiv.classList.add('slds-size_5-of-12');
        }
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