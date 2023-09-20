import { LightningElement, api } from 'lwc';

export default class DynamicProgressIndicator extends LightningElement {
    @api recordId;
    @api recordIdFieldApiName;
    @api progressStatusFieldApiName;

    @api type;
    @api variant
    @api progressSteps;

    @api allStepsCompleteLabel
    @api allStepsCompleteValue;

    @api hasError;
    @api errorMessage
    @api disableStepCompletion;
    @api disableStepCompletionButtonLabel;
    @api currentStep
}