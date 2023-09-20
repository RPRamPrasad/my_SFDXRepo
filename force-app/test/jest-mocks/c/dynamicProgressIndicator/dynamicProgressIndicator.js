import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class DynamicProgressIndicator extends LightningElement {
    @api recordId;
    @api recordIdFieldApiName;
    @api progressStatusFieldApiName;

    @api type = 'base';
    @api variant = 'base'
    @api progressSteps = [];
    _currentStep

    @api allStepsCompleteLabel = "All Steps Completed"
    @api allStepsCompleteValue = 'All_Step_Complete';

    @api hasError = false;
    @api errorMessage = 'Progress has an error';
    @api disableStepCompletion = false;
    @api disableStepCompletionButtonLabel = 'Not Available';

    selectedStep;
    selectedStepBeforeCurrentStep;
    eventAutoFireEnabled;
    stepsWithErrors = [];
    progressWithFinalStep = [];

    @api
    get currentStep() {
        return this._currentStep
    }
    set currentStep(value) {
        this._currentStep = value;
    }

    connectedCallback() {
        this.addFinalStep()
        if (!this.currentStep) {
            this.selectedStep = this.progressWithFinalStep[0];
        }
    }
    addFinalStep() {
        for (let i = 0; i < this.progressSteps.length; i++) {
            this.progressWithFinalStep.push(JSON.parse(JSON.stringify(this.progressSteps[i])))
        }
        this.progressWithFinalStep.push({
            value: this.allStepsCompleteValue,
            style: 'display:none;',
            buttonLabel: this.allStepsCompleteLabel
        })
    }
    renderedCallback() {
        this.setupComponent(this.selectedStep ? this.selectedStep.value : this.currentStep);
    }
    setupComponent(progressStepValue) {
        this.findSelectedStepByValue(progressStepValue);
        this.findNextProgressStep();
        this.isSelectedStepBeforeCurrentStep();
        this.setStepsWithErrors();
        this.setButtonLabel();
        this.autoFireEvent();
    }
    setStepsWithErrors() {
        if (this.hasError) {
            this.template.querySelectorAll("lightning-progress-step[data-has-error='true'")
                .forEach(item => {
                    item.classList.add('slds-is-lost', 'slds-is-active');
                });
        }
    }
    autoFireEvent() {
        if (this.selectedStep &&
            this.selectedStep.autoFireEvent &&
            this.eventAutoFireEnabled &&
            !this.selectedStepBeforeCurrentStep) {
            const selectedStepChangeEvent = new CustomEvent('selectedstepchanged', {
                detail: {
                    selectedStep: this.selectedStep,
                    nextStep: this.nextStep
                }
            });
            this.dispatchEvent(selectedStepChangeEvent);
        }
        this.eventAutoFireEnabled = false;
    }
    findSelectedStepByValue(value) {
        this.selectedStep = this.progressWithFinalStep.filter(item => item.value === value)[0];
    }
    findNextProgressStep() {
        for (let x = 0; x < this.progressWithFinalStep.length; x++) {
            if (this.progressWithFinalStep[x].value === this.selectedStep.value) {
                this.selectedStep = this.progressWithFinalStep[x];
                this.nextStep = this.progressWithFinalStep[x + 1];
            }
        }
    }
    handleProgressClick(event) {
        if(event.target.value) {
            this.setupComponent(event.target.value);
            const selectedStepChangeEvent = new CustomEvent('selectedstepchanged', {
                detail: {
                    selectedStep: this.selectedStep,
                    nextStep: this.nextStep,
                    selectedStepBeforeCurrentStep: this.selectedStepBeforeCurrentStep
                }
            });
            this.dispatchEvent(selectedStepChangeEvent);
        }
    }
    async handleStageCompleteClick() {
        const stageCompleteButton = this.template.querySelector("[data-id='stageCompleteButton']");
        stageCompleteButton.disabled = true
        this.eventAutoFireEnabled = true;
        const fields = {};
        fields[this.recordIdFieldApiName] = this.recordId;

        if (this.selectedStepBeforeCurrentStep) {
            fields[this.progressStatusFieldApiName] = this.selectedStep.value;
        } else {
            fields[this.progressStatusFieldApiName] = this.nextStep.value;
        }
        const recordData = { fields };
        try {
            await updateRecord(recordData)
            let toast;
            if (this.selectedStepBeforeCurrentStep) {
                toast = this.selectedStep.movedBackwardToast;
            } else {
                toast = this.selectedStep.movedForwardToast;
            }

            if (toast && toast.showOnCompleteSuccess) {
                this.createToastEvent('success', toast.successTitle, toast.successMessage)
            }
            const successEvent = new CustomEvent('progressstepcompleted', {
                detail: {
                    completedStep: this.selectedStep,
                    nextStep: this.nextStep
                }
            });
            this.dispatchEvent(successEvent);
            if (!this.selectedStepBeforeCurrentStep) {
                this.setupComponent(this.nextStep.value);
            }
        } catch (error) {
            let toast;
            if (this.selectedStepBeforeCurrentStep) {
                toast = this.selectedStep.movedBackwardToast;
            } else {
                toast = this.selectedStep.movedForwardToast;
            }
            if (toast && toast.showOnCompleteError) {
                this.createToastEvent('error', toast.errorTitle, JSON.stringify(error))
            }
        }
    }
    createToastEvent(variant, title, message) {
        const toastEvent = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }
    setButtonLabel() {
        let label;
        let disabled;
        if (this.selectedStep.disabled) {
            label = this.selectedStep.disabledButtonLabel ? this.selectedStep.disabledButtonLabel : 'Not Available';
            disabled = true;
        } else if (this.selectedStep.value === this.allStepsCompleteValue && !this.selectedStepBeforeCurrentStep) {
            label = this.allStepsCompleteLabel;
            disabled = true;
        } else if (this.selectedStepBeforeCurrentStep) {
            label = this.selectedStep.revertButtonLabel ? this.selectedStep.revertButtonLabel : 'Reset to Step';
        } else {
            label = this.selectedStep && this.selectedStep.buttonLabel ? this.selectedStep.buttonLabel : 'Mark Step Completed';
        }
        const stageCompleteButton = this.template.querySelector("[data-id='stageCompleteButton']");
        stageCompleteButton.removeChild(stageCompleteButton.childNodes[0]);
        if (this.disableStepCompletion === true || this.disableStepCompletion === 'true') {
            disabled = true;
            label = this.disableStepCompletionButtonLabel;
        }
        stageCompleteButton.appendChild(document.createTextNode(label));
        stageCompleteButton.disabled = disabled;
    }
    isSelectedStepBeforeCurrentStep() {
        let currentIndex = this.getStepIndex(this.currentStep)
        let selectedIndex = this.getStepIndex(this.selectedStep.value)
        if (selectedIndex < currentIndex) {
            this.selectedStepBeforeCurrentStep = true;
        } else {
            this.selectedStepBeforeCurrentStep = false;
        }
    }
    getStepIndex(step) {
        for (let i = 0; i < this.progressWithFinalStep.length; i++) {
            if (step === this.progressWithFinalStep[i].value) {
                return i;
            }
        }
        return null
    }
}