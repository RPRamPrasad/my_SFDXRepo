import { createElement } from "lwc";
import ha4cPKCE from "c/ha4cPKCE";
import getVFOrigin from "@salesforce/apex/HA4C_PKCE.getVFOrigin";
import getHA4CToken from "@salesforce/apex/HA4C_PKCE.getHA4CToken";
import getPolicyDetailsParmHA4C from "@salesforce/apex/Ha4cWebController.getPolicyDetailsParmHA4C";
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { getNavigateCalledWith } from "lightning/navigation";
const WORKSTATION_ID = "WPWFZRNF";
const VF_ORIGIN = 'https://statefarm--pdnndforce--c.visualforce.com';
const TOKEN_WO_DEVICE_ID =
    "eyJ0eXAiOiJKV1QiLCJub25jZSI6IlZXaFItb1FNWFJUY19DbkZFNXN2b1Z0bVVRVFR0RnFRYWUxcUZrZ2RuWWciLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.e30=";
const TOKEN_W_DEVICE_ID =
    "eyJ0eXAiOiJKV1QiLCJub25jZSI6IlZXaFItb1FNWFJUY19DbkZFNXN2b1Z0bVVRVFR0RnFRYWUxcUZrZ2RuWWciLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJkZXZpY2VpZCI6IjU0ODVlYmExLTEyNTQtNDM3OS04ZmI5LWM4ODE5ZGI4YTAyMyJ9";
const PARM_STRING = "https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=0010455&selPolOpt=6&lob=A&caseID=5001b00000CIMg2AAH&associateID=VLGVS5ZW9AK&clientID=HFQ629WX7WA";

// Mocking imperative Apex method call
jest.mock(
    "@salesforce/apex/HA4C_PKCE.getVFOrigin",
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/HA4C_PKCE.getHA4CToken",
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/HA4C_PKCE.getVFOrigin",
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/Ha4cWebController.getPolicyDetailsParmHA4C",
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

const triggerListenerEffect = (data) => {
    const message = {
        origin: VF_ORIGIN,
    };
    if (data) {
        message.data = data;
    }
    const messageEvent = new MessageEvent("message", message);
    window.dispatchEvent(messageEvent);
};

describe("c-ha4c-p-k-c-e", () => {
    const { location } = window;
    const unmockedFetch = global.fetch;

    beforeAll(() => {
        delete window.location;
        window.location = {
            href: "https://example.com",
        };
    });

    beforeEach(() => {
        // Prevent data saved on mocks from leaking between tests
        window.sessionStorage.clear();
        jest.clearAllMocks();
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    afterAll(() => {
        window.location = location;
        global.fetch = unmockedFetch;
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    const { setImmediate } = require("timers");
    function flushPromises() {
        return new Promise((resolve) => setImmediate(resolve));
    }

    it("test publish call not made when workstationId not present from session storage", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });

        document.body.appendChild(element);

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
    });

    it("test calls publish based on workstation Id from session storage", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        window.sessionStorage.setItem("ha4c_workstation_id", WORKSTATION_ID);
        //navigateToWeb(WORKSTATION_ID);
        document.body.appendChild(element);

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).toBeNull();
    });

    it("test lookUpWorkstationId with access token and no deviceId", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_WO_DEVICE_ID);
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).not.toHaveBeenCalled();
    });

    it("test lookUpWorkstationId with access token and deviceId", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_W_DEVICE_ID);
        global.fetch = jest.fn(() =>
            Promise.resolve({
                json: () =>
                    Promise.resolve({
                        value: [{ displayName: WORKSTATION_ID }],
                    }),
                status: 200,
            })
        );

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).toHaveBeenCalled();
    });

    it("test should fail when displayName not present in resposne of callMSGraph", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_W_DEVICE_ID);
        global.fetch = jest.fn(() =>
            Promise.resolve({
                json: () =>
                    Promise.resolve({
                        value: [],
                    }),
                status: 200,
            })
        );

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).toHaveBeenCalled();
        let fetchResponse = await global.fetch.mock.results[0].value;
        expect(fetchResponse.status).toBe(200);
        expect(window.sessionStorage.getItem('ha4c_workstation_id')).toBe('unknown');
    });

    it("validates fetch endpoint and options", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_W_DEVICE_ID);
        global.fetch = jest.fn(() =>
            Promise.resolve({
                json: () =>
                    Promise.resolve({
                        value: [{ displayName: WORKSTATION_ID }],
                    }),
                status: 200,
            })
        );
        const deviceId = JSON.parse(
            window.atob(TOKEN_W_DEVICE_ID.split(".")[1])
        ).deviceid;
        const endpoint = `https://graph.microsoft.com/v1.0/devices?$filter=deviceId+eq+'${deviceId}'&$select=displayName`;
        const options = {
            method: "GET",
            headers: {
                Authorization: `Bearer ${TOKEN_W_DEVICE_ID}`,
                "Content-Type": "application/json",
                Accept: "application/json",
                ConsistencyLevel: "eventual",
            },
        };

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).toHaveBeenCalledWith(endpoint, options);
        expect(window.sessionStorage.getItem('ha4c_workstation_id')).toBe(WORKSTATION_ID);
    });

    it("test exception for callMSGraph", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_W_DEVICE_ID);
        // sending 400 response when fetch function gets called
        global.fetch = jest.fn(() =>
            Promise.resolve({
                json: () =>
                    Promise.resolve({
                        value: [{ displayName: WORKSTATION_ID }],
                    }),
                status: 400,
            })
        );

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).toHaveBeenCalled();
        let fetchResponse = await global.fetch.mock.results[0].value;
        expect(fetchResponse.status).toBe(400);
        expect(window.sessionStorage.getItem('ha4c_workstation_id')).toBe('unknown');
    });

    it("test network error for callMSGraph", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        getHA4CToken.mockResolvedValue(TOKEN_W_DEVICE_ID);
        // sending error response when fetch function gets called
        global.fetch = jest.fn(() => Promise.reject(new Error("Error")));

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).toHaveBeenCalled();
        expect(window.sessionStorage.getItem('ha4c_workstation_id')).toBe('unknown');
    });

    it("test handleAuthResponse without message data", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({}));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).not.toHaveBeenCalled();
    });

    it("test message event listener when vf page is ready", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        // Mocking the querySelector for the iframe
        const iframeMock = {
            contentWindow: {
                postMessage: jest.fn(),
            },
        };
        jest
            .spyOn(element.shadowRoot, "querySelector")
            .mockImplementation((selector) => {
                if (selector === "iframe") {
                    return iframeMock;
                }
                return iframeMock;
            });

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cVfReady: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(iframeMock.contentWindow.postMessage).toHaveBeenCalledWith(
            JSON.stringify({ ha4cPkceLogin: true }),
            VF_ORIGIN
        );
    });

    it("make sure removeEventListener fires and rendered callback happens only once", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        window.sessionStorage.setItem("ha4c_workstation_id", WORKSTATION_ID);
        const removeEventListenerMock = jest.spyOn(window, "removeEventListener");

        getPolicyDetailsParmHA4C.mockResolvedValue(PARM_STRING);

        document.body.appendChild(element);
        document.body.removeChild(element);
        document.body.appendChild(element);

        await flushPromises();
        expect(removeEventListenerMock.mock.calls[0][0]).toEqual("message");
        // get the navigate event params and validate
        let navigateParmas = getNavigateCalledWith();
        expect(navigateParmas.pageReference.type).toEqual('standard__webPage');
        expect(navigateParmas.pageReference.attributes.url).toEqual('https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=0010455&selPolOpt=6&lob=A&caseID=5001b00000CIMg2AAH&associateID=VLGVS5ZW9AK&clientID=HFQ629WX7WA&workstationID=' + WORKSTATION_ID + '&pgmName=PCA21&callingApp=Case');
    });

    it("origins do not match", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue("");
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cVfReady: true }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(global.fetch).not.toHaveBeenCalled();
    });

    it("bad message json", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue("");
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect(null);
        triggerListenerEffect(undefined);
        triggerListenerEffect("123");
        triggerListenerEffect(123);
        triggerListenerEffect(false);

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(getHA4CToken).not.toHaveBeenCalled();
        expect(global.fetch).not.toHaveBeenCalled();
    });

    it("test handleAuthResponse with false", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: false }));

        await flushPromises();
        expect(element.shadowRoot.querySelector("iframe")).not.toBeNull();
        expect(getHA4CToken).not.toHaveBeenCalled();
        expect(global.fetch).not.toHaveBeenCalled();
    });

    it("test handleAuthResponse with invalid event data", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getVFOrigin.mockResolvedValue(VF_ORIGIN);
        global.fetch = jest.fn();

        document.body.appendChild(element);
        triggerListenerEffect("Invalid event json data");

        await flushPromises();
        expect(getHA4CToken).not.toHaveBeenCalled();
    });

    it("test navigateToWeb success", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getPolicyDetailsParmHA4C.mockResolvedValue(PARM_STRING);
        global.fetch = jest.fn();

        // Listen to ShowToastEvent
        const showToastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHandler);

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: false }));

        await flushPromises();
        expect(getPolicyDetailsParmHA4C).toHaveBeenCalled();
        expect(showToastHandler).not.toHaveBeenCalled();
        // get the navigate event params and validate
        let navigateParmas = getNavigateCalledWith();
        expect(navigateParmas.pageReference.type).toEqual('standard__webPage');
        expect(navigateParmas.pageReference.attributes.url).toEqual('https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=0010455&selPolOpt=6&lob=A&caseID=5001b00000CIMg2AAH&associateID=VLGVS5ZW9AK&clientID=HFQ629WX7WA&workstationID=unknown&pgmName=PCA21&callingApp=Case');
    });

    it("test navigateToWeb error", async () => {
        const element = createElement("c-ha4c-p-k-c-e", {
            is: ha4cPKCE,
        });
        getPolicyDetailsParmHA4C.mockRejectedValue("ERROR");
        global.fetch = jest.fn();

        // Listen to ShowToastEvent
        const showToastHandler = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHandler);

        document.body.appendChild(element);
        triggerListenerEffect(JSON.stringify({ ha4cToken: false }));

        await flushPromises();
        expect(getPolicyDetailsParmHA4C).toHaveBeenCalled();
        expect(showToastHandler).toHaveBeenCalled();
        expect(showToastHandler.mock.calls[0][0].detail.title).toBe('Launch to Necho Status');
        expect(showToastHandler.mock.calls[0][0].detail.variant).toBe('Error');
        expect(showToastHandler.mock.calls[0][0].detail.message).toBe('The operation couldnt be completed (Status: undefined ). Please contact WG11255.');
    });

});