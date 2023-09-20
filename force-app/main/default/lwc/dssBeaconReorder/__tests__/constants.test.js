import * as constants from '../constants';
import testConstants from './data/constants.json';

describe('c-dss-beacon-reorder constants', () => {

    it('should test error codes', async () => {
        expect(constants.DSS_INACTIVE_ERROR_CODE).toEqual(testConstants.DSS_INACTIVE_ERROR_CODE);
        expect(constants.BEACON_SHIPPED_ERROR_CODE).toEqual(testConstants.BEACON_SHIPPED_ERROR_CODE);
        expect(constants.CCC_BEACON_SHIPPED_ERROR_CODE).toEqual(testConstants.CCC_BEACON_SHIPPED_ERROR_CODE);
        expect(constants.NO_ENROLLMENT_DATE_ERROR_CODE).toEqual(testConstants.NO_ENROLLMENT_DATE_ERROR_CODE);
        expect(constants.INCORRECT_PRODUCT_CODE_ERROR_CODE).toEqual(testConstants.INCORRECT_PRODUCT_CODE_ERROR_CODE);
        expect(constants.TECHNICAL_ERROR_CODE).toEqual(testConstants.TECHNICAL_ERROR_CODE);
        expect(constants.CCC_TECHNICAL_ERROR_CODE).toEqual(testConstants.CCC_TECHNICAL_ERROR_CODE);
    });

    it('should test page content', async () => {
        expect(constants.PAGE_1_BODY).toEqual(testConstants.PAGE_1_BODY);
        expect(constants.PAGE_2_BODY).toEqual(testConstants.PAGE_2_BODY);
        expect(constants.PAGE_3_BODY).toEqual(testConstants.PAGE_3_BODY);
        expect(constants.PAGE_4_BODY).toEqual(testConstants.PAGE_4_BODY);
        expect(constants.PAGE_30_BODY).toEqual(testConstants.PAGE_30_BODY);
        expect(constants.PAGE_31_BODY).toEqual(testConstants.PAGE_31_BODY);
        expect(constants.PAGE_32_BODY).toEqual(testConstants.PAGE_32_BODY);
        expect(constants.PAGE_33_BODY).toEqual(testConstants.PAGE_33_BODY);
        expect(constants.PAGE_99_BODY).toEqual(testConstants.PAGE_99_BODY);
        expect(constants.PAGE_100_BODY).toEqual(testConstants.PAGE_100_BODY);
        expect(constants.PAGE_101_BODY).toEqual(testConstants.PAGE_101_BODY);
    });

    it('should test reorder reasons', async () => {
        expect(constants.REORDER_REASONS).toEqual(testConstants.REORDER_REASONS);
        expect(constants.REORDER_REASONS_CCC).toEqual(testConstants.REORDER_REASONS_CCC);
    });
});