import { api, track, LightningElement } from 'lwc';
import create_UUID from './uuidUtility';
import distributeEvenly from './distributionUtility';
import evaluateTrue from './trueComparisonUtility';
import { sortUserByName } from 'c/userUtilities';
import assignRecordsByUserCount from '@salesforce/apex/AssignToController.assignRecordsByUserCountAndIdList';
import assignRecordsByCampaignMember from '@salesforce/apex/AssignToController.assignRecordsByCampaignMember';
import sendBulkAssignmentEmail from '@salesforce/apex/AssignToEmail.sendBulkAssignmentEmails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BulkAssignTo extends LightningElement {
    
    @api selectPlaceHolder = "Select a User";

    _usersToAssignTo;
    _recordsToAssign;

    @api sObjectType;
    @api assignToField;
    @api isAssignToDisabled;
    @api assignedTodisabledReason = "Assign button is disabled for support users at this time.";

    @api disableAssignmentOverwriteWarning = false;

    @api showSuccessToast = false;
    @api successToastTitle = "Record Assignment Success";
    @api successToastMessage = " Campaign Members successfully assigned";

    @api errorToastTitle = "Error Occurred";
    @api errorToastMessage = "An error occurred during assignment. Please contact your normal support channel for assistance.";

    @api createChatterPost = false;
    @api chatterPostDescription = "Records assigned to the following users";

    @api sendEmail = false;
    @api emailSubject = "Salesforce Records Assigned To Users";
    @api emailMessage = "The following users have been assigned records on Salesforce";

    @api recordId;
    @api recordType = "SObject";
    @api recordLabel = "Record";
    @api recordLabelPlural = "Records";

    @track totalNumberEntered = 0;
    @track totalNumberRemaining;

    @track displayTooManyError = true;
    @track assignDisabled = true;

    @track userAssignToInputs;

    @track showSpinner = false;

    @track displayAssignTo;
    @track displayOverwriteWarning;
    @track numberOfRecordsThatWillBeOverwritten = 0;
    @track hasRecordsToAssign;
    @track hasUsersToAssignTo;

    @track userComboOptions = [];
    @track showUserSelection = false;
    sortedAssignToUsers;

    recordIdList;

    assignMethod = 'number';
      

    get assignmentOptions() {
        return [
            { label: 'Number', value: 'number' },
            { label: 'Last Name', value: 'lastName' }
        ];
    }

    @api 
    get recordsToAssign() {
        return this._recordsToAssign;
    }

    set recordsToAssign(value) {
        this._recordsToAssign = value;
        this.hasRecordsToAssign = value && value.length  > 0

        this.initialize();
    }

    @api 
    get usersToAssignTo() {
        return this._usersToAssignTo;
    }

    set usersToAssignTo(value) {
        this._usersToAssignTo = value;
        this.hasUsersToAssignTo = value && value.length > 0;
        this.initialize();
    }

    get numberMethod() {
      if (this.assignMethod === 'number') {
        return true;
      }
      return false;
    }

    get displayAddUser() {
      return (this.userAssignToInputs.length < this.usersToAssignTo.length) && !this.addUserDisabled;
   }

    get totalRecordsToAssign() {
      return this.recordsToAssign.length;
    }

    connectedCallback() {
        this.initialize();
    }

    initialize() {
        if (this.hasRecordsToAssign && this.hasUsersToAssignTo) {
            this.determineIfOverwriteAssignment();
            this.userAssignToInputs = [];
            this.totalNumberRemaining = this.recordsToAssign.length;
            this.sortedAssignToUsers = this.usersToAssignTo.slice(0);
            this.sortedAssignToUsers.sort(sortUserByName);
            this.setRecordIdList();
            this.sortedAssignToUsers.forEach(element => {
                this.userAssignToInputs.push({
                    inputId: create_UUID(),
                    selectedUser: element,
                    numberOfRecordsToAssign: 0,
                    numberOfRecordsToAssignIsValid: true
                })
            });
        }
    }

    setRecordIdList() {
        this.recordIdList = this.recordsToAssign.map(item => item.Id);
    }

    determineIfOverwriteAssignment() {
        if (!this.disableAssignmentOverwriteWarning) {
            const recordsThatWillBeOverwritted = this.recordsToAssign.filter(item => item[this.assignToField]); 
            this.numberOfRecordsThatWillBeOverwritten = recordsThatWillBeOverwritted.length;
            this.displayOverwriteWarning = this.numberOfRecordsThatWillBeOverwritten > 0;
            this.displayAssignTo = !this.displayOverwriteWarning;
        } else {
            this.displayOverwriteWarning = false;
            this.displayAssignTo = true;
        }
    }

    handleAssignMethod(event) {
        this.assignMethod = event.detail.value;
        this.userAssignToInputs.forEach( user => {
          user.numberOfRecordsToAssign = 0;
          user.numberOfRecordsToAssignIsValid = true;
          user.letters = [];
          user.members = [];
        });
        
        const modalContainer = this.template.querySelector('[data-id="contentOption"]');
        if(this.assignMethod === 'lastName') {
          modalContainer.style.width = "450px";
        } else {
          modalContainer.style.width = "400px";
        }

        const assignToInputs = this.template.querySelectorAll('c-assign-to-input');
        assignToInputs.forEach(input => {
          input.changeGridDimensions(this.assignMethod);
        })
        
    }
    
    handleNumberEntryChange(event) {
        let changedInput = this.userAssignToInputs.filter(item => item.inputId === event.detail.assignToInputId)[0];
        changedInput.numberOfRecordsToAssign = event.detail.newValue;
        changedInput.numberOfRecordsToAssignIsValid = event.detail.isValid;

        this.enableAssignment();
    }

    handleLetterEntry(event){
      let currentUser = this.userAssignToInputs.filter(item => item.inputId === event.detail.assignToInputId)[0];
      currentUser.letters = event.detail.letters;

      this.findLastNames(currentUser);
      currentUser.numberOfRecordsToAssign = currentUser.members.length;
      currentUser.numberOfRecordsToAssignIsValid = true;

      this.enableAssignment();
    }

    findLastNames(user) {
      user.members = []; 
      user.letters.forEach( (letter) => {
        this._recordsToAssign.forEach( (record) => {
          let firstLetter;
          if(record.LastName) {
            firstLetter = record.LastName.substring(0,1);
          } else {
            firstLetter = record.DisplayName__c.substring(0,1);
          }
          
          if(letter === firstLetter.toUpperCase()) {
            user.members.push(record.Id);
          }
        });
      });
    }

    handleRemoveRow(event) {
        this.addUserDisabled = false;
        this.showUserSelection = false;

        let eventInputId = event.detail.assignToInputId;

        this.buildRemovedUserOptions(event.detail.selectedUserId)
        
        let assignToInputToKeep = this.userAssignToInputs.filter(item => item.inputId !== eventInputId);
        this.userAssignToInputs = assignToInputToKeep;

        this.enableAssignment();
    }

    buildRemovedUserOptions(userId) {
        let userName = this.userAssignToInputs.filter(item => item.selectedUser.Id === userId)[0].selectedUser.Name;
        this.userComboOptions.push({ label: userName, value: userId })
    }

    handleSelectChange(event) {
        this.showUserSelection = false;
        this.addUserDisabled = false;

        this.addUser(event.detail.value)
    }

    async addUser(userId) {
        let userSelected = this.sortedAssignToUsers.filter(item => item.Id === userId)[0];

        this.userComboOptions = this.userComboOptions.filter(item => item.value !== userId);

        this.userAssignToInputs.push({
            inputId: create_UUID(),
            selectedUser: userSelected,
            numberOfRecordsToAssign: 0,
            numberOfRecordsToAssignIsValid: true,
            letters: [],
            members: []
        })

        let scrollableDiv = await this.template.querySelector('div[data-id="scrollableUserList"')
        scrollableDiv.scrollTop = scrollableDiv.scrollHeight

        const assignToInputs = await this.template.querySelectorAll('c-assign-to-input');
        const userAddedPosition = this.userAssignToInputs.length - 1;
        assignToInputs[userAddedPosition].changeGridDimensions(this.assignMethod); 

    }
    
    hideUserSelection() {
        this.showUserSelection = false;
        this.addUserDisabled = false;
    }

    handleAddUser() {
        if(this.userComboOptions.length === 1) {
            this.addUser(this.userComboOptions[0].value)
        } else {
            this.showUserSelection = true;
        }
        this.addUserDisabled = true;
    }

    distributeEvenly() {
        let numberOfUsers = this.userAssignToInputs.length;
        let numberOfRecords = this.recordsToAssign.length;

        let values = distributeEvenly(numberOfUsers, numberOfRecords);

        for (let x = 0; x < this.userAssignToInputs.length; x++) {
            this.userAssignToInputs[x].numberOfRecordsToAssign = values[x];
            this.userAssignToInputs[x].numberOfRecordsToAssignIsValid = true;
        }

        this.enableAssignment();
    }

    enableAssignment() {
        this.calculateTotalEntered();
        this.totalNumberRemaining = this.recordsToAssign.length - this.totalNumberEntered;
        if(this.isAssignToDisabled){
            this.assignDisabled = true;
        } else { 
            if (this.totalNumberEntered === this.recordsToAssign.length && this.validateInputs()) {
                this.displayTooManyError = false;
                this.assignDisabled = false;
            } else {
              
                this.displayTooManyError = true;
                this.assignDisabled = true;
            }
        }
    }

    calculateTotalEntered() {
        let sum = 0;

        this.userAssignToInputs.forEach(item => {
            if (item.numberOfRecordsToAssign && !isNaN(item.numberOfRecordsToAssign)) {
                sum += parseInt(item.numberOfRecordsToAssign, 10);
            }
        });

        this.totalNumberEntered = sum;
    }

    validateInputs() {
        return !this.userAssignToInputs.some(item => !item.numberOfRecordsToAssignIsValid);
    }

    performNumberAssignment() {
        this.showSpinner = true;
        assignRecordsByUserCount({ sObjectIds: this.recordIdList, assignToField: this.assignToField, userRecordCounts: JSON.stringify(this.buildUserRecordCounts()) })
            .then(result => {
                if(result) {
                    this.email(result);
                    this.raiseSuccessEvent(result);
                    this.raiseToastSuccessEvent(result);

                } else {
                    this.dispatchEvent(new CustomEvent('assignmenterror'));
                    this.raiseToastErrorEvent();
                }

                this.showSpinner  = false;
            });
    }

    performAlphaAssignment() {
      this.showSpinner = true;

      assignRecordsByCampaignMember({ campaignMemberAssignment: this.buildCampaignMemberRecords(), userRecordCounts: this.buildUserRecordCounts()})
          .then(result => {
              if(result) {
                  this.email(result);
                  this.raiseSuccessEvent(result);
                  this.raiseToastSuccessEvent(result);

              } else {
                  this.dispatchEvent(new CustomEvent('assignmenterror'));
                  this.raiseToastErrorEvent();
              }
              
              this.showSpinner  = false;
          });
    }

    cancelAssignment() {
        const event = new CustomEvent('assignmentcancel');
        this.dispatchEvent(event);
    }

    handleOverwriteOkay() {
        this.displayAssignTo = true;
        this.displayOverwriteWarning = false;
    }

    buildUserRecordCounts() {
        let userRecordCounts = [];
        this.userAssignToInputs
            .filter(item =>
                item.numberOfRecordsToAssign
                && !isNaN(item.numberOfRecordsToAssign)
                && item.numberOfRecordsToAssign > 0)
            .forEach(item => {
                userRecordCounts.push({ userId: item.selectedUser.Id
                    , numberOfRecordsToAssign: item.numberOfRecordsToAssign
                    , userFullName: item.selectedUser.Name });
            });
        return userRecordCounts;
    }

    buildCampaignMemberRecords() {
      let campaignMemberObjects = [];
      
      this.userAssignToInputs
      .filter(user =>
          user.numberOfRecordsToAssign > 0)
      .forEach(user => {
          user.members.forEach( member => {
            campaignMemberObjects.push(
              { Id: member,
                [this.assignToField]: user.selectedUser.Id});
          })
      });
      return campaignMemberObjects;
    }

    email(result) {
      if (evaluateTrue(this.sendEmail)) {
        sendBulkAssignmentEmail({
            emailOptions : {
                recordId : this.recordId,
                subject: this.emailSubject,
                message: this.emailMessage,
                recordType: this.recordType,
                recordLabel: this.recordLabel,
                recordLabelPlural: this.recordLabelPlural
            },
            userRecordCounts: result.userRecordCounts
        })
      }
    }

    raiseSuccessEvent(result) {
      const customEvent = new CustomEvent('assignmentsuccess',
                        {
                            composed: false,
                            bubbles: false,
                            cancelable: false,
                            detail: {
                                sObjects: result.userRecordCounts
                            }
                        });
      this.dispatchEvent(customEvent);
    }

    raiseToastSuccessEvent(result) {
      if (this.showSuccessToast) {
        const successToast = new ShowToastEvent({
            title: this.successToastTitle,
            message: result.numberOfRecordsAssignedSuccess + " of " + this.recordsToAssign.length+ this.successToastMessage,
            variant: 'success'
        });
        this.dispatchEvent(successToast);
      }
    }

    raiseToastErrorEvent() {
      const customEvent = new ShowToastEvent({
                      title: this.errorToastTitle,
                      message: this.errorToastMessage,
                      variant: 'error'
                       });
      this.dispatchEvent(customEvent);
    }
}