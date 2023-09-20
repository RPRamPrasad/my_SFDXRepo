const name = { label: 'Claim Number', fieldName: 'Claim.Name'}
const status = { label: 'Claim Status', fieldName: 'Claim.Status'}
const assetDescription = { label: 'Claim Asset Description', fieldName: 'AssetDescription__c'}
const lostDate = { label: 'Date of Loss', fieldName: 'Claim.LossDate__c', type: 'date', typeAttributes: {timeZone:'UTC', month: 'numeric', day: 'numeric', year: 'numeric'}}
const participantName = { label: 'Customer', fieldName: 'ParticipantAccountId', type: 'url', typeAttributes: {label: { fieldName: 'ParticipantName__c' }, target: '_self'}}

const claimNumber = { label: 'Claim Number', fieldName: 'Id', type: 'claimDatatableUrl', typeAttributes: { label: { fieldName: 'Name' }, url: { fieldName: 'Id' } } }
const claimStatus = { label: 'Claim Status', fieldName: 'Status'}
const claimAssetDescription = { label: 'Claim Asset Description', fieldName: 'ClaimDescription__c'}
const policyNumber = { label: 'Policy Number', fieldName: 'PolicyNumberId', type: 'claimDatatableUrl', typeAttributes: { label: { fieldName: 'PolicyNumber.Name' }, url: { fieldName: 'PolicyNumberId' } } }
const claimLossDate = { label: 'Date of Loss', fieldName: 'LossDate__c', type: 'date', typeAttributes: {timeZone:'UTC', month: 'numeric', day: 'numeric', year: 'numeric'} }
const customer = { label: 'Customer', fieldName: 'AccountId', type: 'url', typeAttributes: { label: { fieldName: 'Account.Name' }, target: '_self' } }

export const CLAIMANT_COLUMNS = [
    name,
    status,
    assetDescription,
    lostDate
];

export const HOUSEHOLD_CLAIMANT_COLUMNS = [
    name,
    status,
    assetDescription,
    lostDate,
    participantName
];

export const CLAIMS_COLUMNS = [
    claimNumber,
    claimStatus,
    claimAssetDescription,
    policyNumber,
    claimLossDate,
    customer
];