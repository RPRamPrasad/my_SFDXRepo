import { LightningElement, api } from 'lwc';

const ALPHABET = [ 'A', 'B', 'C', 'D', 'E','F', 'G', 'H', 'I', 'J','K', 'L', 'M', 'N', 'O','P', 'Q', 'R', 'S', 'T','U', 'V', 'W', 'X', 'Y','Z' ];

export default class AssignToInputByAlpha extends LightningElement {

  @api inputId;
  @api numberOfRecordsToAssign = 0;
  @api userSelections;
  
  firstEntry;
  secondEntry;
  selectedLetters;
  errorMessage;
     
  handleFirstEntry(event) {
    const entry = event.target.value.toUpperCase();
    this.firstEntry = entry;
    event.target.value = entry;
        
    this.validateEntries();
  }

  handleSecondEntry(event) {
    const entry = event.target.value.toUpperCase();
    this.secondEntry = entry;
    event.target.value = entry;
        
    this.validateEntries();
  }

  validateEntries () {
    this.selectedLetters = [];
    this.errorMessage = undefined;
    
    if(this.firstEntry && this.secondEntry) {
      if(!this.isPatternMismatch() ) {
        this.selectedLetters = this.findLettersInCurrentRange();
        this.checkForOverlap();
      }
    }
    this.dispatchCustomEvent("userletterentry", { assignToInputId: this.inputId, 
      selection: this.selectedLetters,
      message: this.errorMessage});
  }

  isPatternMismatch() {
    const firstEntryInput = this.template.querySelector("[data-id='firstLetter']");
    const secondEntryInput = this.template.querySelector("[data-id='secondLetter']");
    
    if (firstEntryInput.validity.patternMismatch | secondEntryInput.validity.patternMismatch) {
      this.errorMessage = 'Please enter lower or upper case letters.';
      return true;
    }
    return false;
  }

  findLettersInCurrentRange() {
    const min = Math.min(this.numberCode(this.firstEntry), this.numberCode(this.secondEntry));

    const max = Math.max(this.numberCode(this.firstEntry), this.numberCode(this.secondEntry));
    const letters=[];
    
    ALPHABET.forEach(letter => {
      let letterAscii = this.numberCode(letter);
      if(letterAscii >= min && letterAscii <= max ) {
        letters.push(letter);
      }
    });    
    
    return letters;
  }

  numberCode(letter) {
    // Converts letter to ASCII decimal: A = 65; Z = 90
    return letter.charCodeAt();
  }

  checkForOverlap() {
    const lettersAlreadyChosen = this.captureAllUserSelections();
    const overlap = this.selectedLetters.some( letter => {return lettersAlreadyChosen.includes(letter)});
    
    if(overlap){
      this.errorMessage = `The range "${this.firstEntry} - ${this.secondEntry}" overlaps with another user's range.`;
    } 
  }
  
  captureAllUserSelections() {
    const lettersChosen = [];
    
    this.userSelections.forEach(user => {
      if(this.inputId !== user.inputId) {
        user.letters.forEach(letter => {
          lettersChosen.push(letter);
        })
      }
    })
    return lettersChosen;

  }  

  dispatchCustomEvent(eventName, eventDetails) {
    const customEvent = new CustomEvent(eventName, 
        {
            composed: false,
            bubbles: true,
            cancelable: false,
            detail: eventDetails
        });
    this.dispatchEvent(customEvent);
  }

}