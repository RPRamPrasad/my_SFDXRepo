import { api, LightningElement } from 'lwc';
export default class BulkAssignTo extends LightningElement {
    @api selectPlaceHolder = "Select a User";
    @api sObjectType;
    @api assignToField;
    @api isAssignToDisabled;
    @api assignedTodisabledReason = "Assign button is disabled for support users at this time.";

    @api disableAssignmentOverwriteWarning = false;

    @api showSuccessToast = false;
    @api successToastTitle = "Record Assignment Success";
    @api successToastMessage = "Records successfully assigned";

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

    @api recordsToAssign;
    @api usersToAssignTo;
}