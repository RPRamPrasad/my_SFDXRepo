import { LightningElement, track, api } from 'lwc';
export default class JourneyPreviewData extends LightningElement {
@api journeyPreviewData;

@track columns = [{
     label: 'Steps',
    initialWidth: 100,
    fieldName: 'journeyStepId',
    cellAttributes: { alignment: 'center' },
    type: 'number',
    sortable: false,
     hideDefaultActions: true
 },
 {
     label: 'Estimated Date',
     fieldName: 'estimatedDate',
    initialWidth: 130,
     type: 'date-local',
     typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",
    },
    hideDefaultActions: true
 },
 {
     label: 'Method',
     fieldName: 'contactMethod',
    initialWidth: 110,
     type: 'text',
     sortable: false,
     hideDefaultActions: true
 },
 {
     label: 'Delivery Type',
     fieldName: 'deliveryType',
    initialWidth: 110,
     type: 'text',
     sortable: false,
     hideDefaultActions: true

 },
 {
     label: 'Estimated Cost Per Mail',
     fieldName: 'stepCost',
     cellAttributes: { alignment: 'left' },
     type: 'currency',
     typeAttributes: { currencyCode: 'USD'},
     hideDefaultActions: true
 },
 {
     label: 'Item Number',
     fieldName: 'stepItemIdUrl',
     type: 'url',
     typeAttributes: 
        {
            label: { fieldName: 'stepItemId' }, 
            target: '_blank'
        },
    hideDefaultActions: true
 }

];

}