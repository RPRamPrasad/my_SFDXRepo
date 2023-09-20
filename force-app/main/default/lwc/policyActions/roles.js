import getPrimaryInsurancePolicyParticipant from '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant';

import { constants } from 'c/policyDetailsCommonJS';
const {
    AUTO, FIRE, LIFE, HEALTH
} = constants;

export const retrievePrimaryNamedInsured = async ({ lob, namedInsured, niClientId, niName, niEmail, isPMRLife, niRoleCd, niSecondaryRoleCd, recordId }) => {
    let returnObj = {};


    switch (lob) {
        case AUTO:
        case FIRE:
        case HEALTH:
            returnObj.accountRecordId = namedInsured;
            returnObj.accountClientId = niClientId;
            returnObj.accountName = niName;
            returnObj.accountEmail = niEmail;
            break;
        case LIFE:
            if (isPMRLife) {
                if (niRoleCd === '12' && niSecondaryRoleCd === '1') {
                    // if NamedInsured role codes match this, then no Owner or PNI is present, only ANI, so default account context to that
                    returnObj.accountRecordId = namedInsured;
                    returnObj.accountClientId = niClientId;
                    returnObj.accountName = niName;
                    returnObj.accountEmail = niEmail;
                } else {
                    try {
                        let response = await getPrimaryInsurancePolicyParticipant({ recordId: recordId, lob: lob });

                        returnObj.accountRecordId = response.PrimaryParticipantAccountId;
                        returnObj.accountClientId = response.PrimaryParticipantAccount.ClientIdentifier__c;
                        returnObj.accountName = response.PrimaryParticipantAccount.Name;
                        returnObj.accountEmail = response.PrimaryParticipantAccount.PersonEmail;

                    } catch (err) {
                        returnObj = null;
                    }
                }
            } else {
                returnObj.accountRecordId = namedInsured;
                returnObj.accountClientId = niClientId;
                returnObj.accountName = niName;
                returnObj.accountEmail = niEmail;
            }
            break;
            default:
                returnObj = '';
                break;
    }

    return returnObj;
}