import { LightningElement, api } from 'lwc';
export default class TaskStepPreviewTable extends LightningElement {
    @api
    taskStepData

    columns = [{
        label: 'Subject',
        fieldName: 'Name',
        initialWidth: 130,
        wrapText: true
    },
    {
        label: 'Due Date',
        fieldName: 'Due_Date__c',
        initialWidth: 100,
        type: 'date-local',
        typeAttributes: {
           day: "numeric",
           month: "numeric",
           year: "numeric"
       }
    },
    {
        label: 'Contact Method',
        fieldName: 'Contact_Method__c',
        initialWidth: 135
    },
    {
        label: 'Comments',
        fieldName: 'Task_Description__c',
        wrapText: true
    }
   ];
}