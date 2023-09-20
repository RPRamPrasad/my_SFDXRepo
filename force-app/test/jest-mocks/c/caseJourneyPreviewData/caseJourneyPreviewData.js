import { LightningElement, track, api } from 'lwc';
export default class CaseJourneyPreviewData extends LightningElement {
@api journeyPreviewData;

@track columns = [{
    label: 'Steps',
    initialWidth: 50,
    fieldName: 'journeyStepId',
    cellAttributes: { alignment: 'center' },
    type: 'number',
    sortable: false,
     hideDefaultActions: true
 },
 {
     label: 'Estimated Date',
     fieldName: 'calculatedDate',
    initialWidth: 110,
     type: 'date-local',
     typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    },
    hideDefaultActions: true
 },
 {
     label: 'Method',
     fieldName: 'methodName',
    initialWidth: 180,
     type: 'text',
     sortable: false,
     hideDefaultActions: true
 },
 {
     label: 'Description',
     fieldName: 'description', 
     type: 'text',
     sortable: false,wrapText: true,
     hideDefaultActions: true
 }

];

}