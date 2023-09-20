import callout from '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation';
import { retrieveDetails } from '../enhanceSummary';

jest.mock(
    '@salesforce/apexContinuation/ContinuationCalloutLWC.getContinuation',
    () => ({ default: jest.fn() }), { virtual: true });

describe('enhanceSummary Logic', () => {

    beforeEach(() => {
        callout.mockImplementation(() => jest.fn());
    })

    afterEach(() => {
        jest.clearAllMocks();
        jest.resetModules();
    });

    it('retrieves details correctly', async () => {
        callout.mockResolvedValueOnce({statusCode: 200, body: '{"policy": { "stuff": "things"}}'})

        const res = await retrieveDetails('lob', 'accesskey', 'sourcecode', '01/01/2000');

        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2000-01-01',
                "sourcecode",
            ]
        }})
        expect(res).toEqual({ stuff: "things" })
    })

    it('retrieves details correctly after 400 date after termination response retry', async () => {
        callout.mockResolvedValueOnce({statusCode: 400, body: '{"errorMsg": "AsofDate is Later than Policy Term End Date: 2002-02-02"}'})
        callout.mockResolvedValueOnce({statusCode: 200, body: '{"policy": { "stuff": "good things"}}'})

        const res = await retrieveDetails('lob', 'accesskey', 'sourcecode', '01/01/2000');

        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2000-01-01',
                "sourcecode",
            ]
        }})
        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2002-02-01',
                "sourcecode",
            ]
        }})
        expect(res).toEqual({ stuff: "good things" })
    })

    it('retrieves details correctly after 400 date before inception response retry', async () => {
        callout.mockResolvedValueOnce({statusCode: 400, body: '{"errorMsg": "AsofDate is Prior to Policy Term Start Date: 2002-02-02"}'})
        callout.mockResolvedValueOnce({statusCode: 200, body: '{"policy": { "stuff": "good things"}}'})

        const res = await retrieveDetails('lob', 'accesskey', 'sourcecode', '01/01/2000');

        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2000-01-01',
                "sourcecode",
            ]
        }})
        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2002-02-02',
                "sourcecode",
            ]
        }})
        expect(res).toEqual({ stuff: "good things" })
    })

    it('handles error for unknown issue from DVL', async () => {
        callout.mockResolvedValueOnce({statusCode: 400, body: '{"errorMsg": "Some random error"}'})
        let res;
        let resErr;

        try {
            res = await retrieveDetails('lob', 'accesskey', 'sourcecode', '01/01/2000');
        } catch(e) {
            resErr = e.message
        }
        expect(resErr).toEqual('Some random error')

        expect(callout).toBeCalledTimes(1);
        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2000-01-01',
                "sourcecode",
            ]
        }})
        expect(res).toBeFalsy();
    })

    it('handles error for 404 not found', async () => {
        callout.mockResolvedValueOnce({statusCode: 404, body: '{"errorMsg": "Policy not found"}'})
        let res;
        let resErr;

        try {
            res = await retrieveDetails('lob', 'accesskey', 'sourcecode', '12/12/2000');
        } catch(e) {
            resErr = e.message
        }
        expect(resErr).toEqual('404: Policy not found')

        expect(callout).toBeCalledTimes(1);
        expect(callout).toHaveBeenCalledWith({ "input": {
            "calloutName": "PolicyDetailsDVLByDate_TP2",
            "calloutParams": [
                "lob",
                "accesskey",
                '2000-12-12',
                "sourcecode",
            ]
        }})
        expect(res).toBeFalsy();
    })
})