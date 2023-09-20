import getPrimaryInsurancePolicyParticipant from '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant';
import { retrievePrimaryNamedInsured } from '../roles';
import { constants } from 'c/policyDetailsCommonJS';

jest.mock(
    '@salesforce/apex/InsurancePolicyController.getPrimaryInsurancePolicyParticipant',
    () => ({ default: jest.fn() }), { virtual: true }
);

const {
    AUTO, FIRE, LIFE, HEALTH
} = constants;

const expectedValuesForNoCallout = {
    accountRecordId : "namedInsured",
    accountClientId : "niClientId",
    accountName: "niName",
    accountEmail: "niEmail"
}

describe('Roles.js can retrieve primary named insured', () => {

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('returns named insured for AUTO', async () => {
        let actual =  await retrievePrimaryNamedInsured( {
            lob: AUTO, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: false, 
            niRoleCd: 'niRoleCd', 
            niSecondaryRoleCd: 'niSecondaryRoleCd', 
            recordId: 'recordId'
        });

        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns named insured for FIRE', async () => {
        let actual =  await retrievePrimaryNamedInsured( {
            lob: FIRE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: false, 
            niRoleCd: 'niRoleCd', 
            niSecondaryRoleCd: 'niSecondaryRoleCd', 
            recordId: 'recordId'
        });

        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns named insured for HEALTH and getPrimaryInsurancePolicyParticipant is not called', async () => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return undefined});
        let actual =  await retrievePrimaryNamedInsured( {
            lob: HEALTH, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: 'niRoleCd', 
            niSecondaryRoleCd: 'niSecondaryRoleCd', 
            recordId: 'recordId'
        });

        expect(getPrimaryInsurancePolicyParticipant).toBeCalledTimes(0);
        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns named insured for LIFE and does not call getPrimaryInsurancePolicyParticipant when role code is 13', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return undefined});
        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '1', 
            recordId: 'recordId'
        });

        expect(getPrimaryInsurancePolicyParticipant).toBeCalledTimes(1);
        expect(actual).toBeNull();
    });

    it('does not call getPrimaryInsurancePolicyParticipant when line of business is LIFE and secondary role code is 2', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return undefined});
        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '12', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(getPrimaryInsurancePolicyParticipant).toBeCalledTimes(1);
        expect(actual).toBeNull();
    });

    it('returns named insured for LIFE when isPMR was true and role code is 12 and secondary role code is 1', async() => {
        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '12', 
            niSecondaryRoleCd: '1', 
            recordId: 'recordId'
        });

        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns named insured for LIFE when isPMR was false', async() => {
        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: false, 
            niRoleCd: '12', 
            niSecondaryRoleCd: '1', 
            recordId: 'recordId'
        });

        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns named insured for LIFE when isPMR was true and role code and secondary role code are not 12 and 1 respectively', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return {
            PrimaryParticipantAccountId: '1234',
            PrimaryParticipantAccount: {
                ClientIdentifier__c: 'abcd',
                Name: 'Charlie Brown',
                PersonEmail: 'charlie.brown@test.com'
            }
        }});

        let expectedValuesWithCallout = {
            accountClientId: 'abcd',
            accountEmail: 'charlie.brown@test.com',
            accountName: 'Charlie Brown',
            accountRecordId: '1234'
        }

        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(getPrimaryInsurancePolicyParticipant).toBeCalledWith({recordId: "recordId", lob: LIFE});
        expect(actual).toEqual(expectedValuesWithCallout);
    });

    it('returns null when getPrimaryInsurancePolicyParticipant does not return results', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return undefined});

        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(getPrimaryInsurancePolicyParticipant).toBeCalledWith({recordId: "recordId", lob: LIFE});
        expect(actual).toBeNull();
    });

    it('returns null when error is thrown in getPrimaryInsurancePolicyParticipant', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {throw new Error('error')});

        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(actual).toBeNull();
    });

    it('does not call retrievePrimaryNamedInsured when line of business is LIFE and isPMRLife is false', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {throw new Error('error')});

        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: false, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });
        expect(getPrimaryInsurancePolicyParticipant).toBeCalledTimes(0);
        expect(actual).toEqual(expectedValuesForNoCallout);
    });

    it('returns null when result from getPrimaryInsurancePolicyParticipant is undefined', async() => {
        getPrimaryInsurancePolicyParticipant.mockImplementation(() => {return undefined});

        let actual =  await retrievePrimaryNamedInsured( {
            lob: LIFE, 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(actual).toBeNull();
    });
    it('returns empty object if an invalid lob is passed in', async() => {
        let actual =  await retrievePrimaryNamedInsured( {
            lob: 'THIS_IS_INVALID', 
            namedInsured: 'namedInsured', 
            niClientId: 'niClientId', 
            niName: 'niName', 
            niEmail: 'niEmail', 
            isPMRLife: true, 
            niRoleCd: '13', 
            niSecondaryRoleCd: '2', 
            recordId: 'recordId'
        });

        expect(actual).toBeFalsy();
    });

});