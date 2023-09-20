import "c/checkBrowser";

/*
description: Function to open the opportunity in the subtab
parameters: opportunityId
parameters: parentTabId
parameters: isFocusedTab
*/
export function openWorkspaceTab(opportunityId, parentTabId, isFocusedTab) {
    return new Promise(function (resolve, reject) {
        invokeWorkspaceAPI('openSubtab', {
            parentTabId: parentTabId,
            url: '/lightning/r/Opportunity/' + opportunityId + '/view',
            focus: isFocusedTab
        })
            .then(() => {
                resolve();
            })
            .catch(() => {
                reject();
            });
    });
}

/*
description: Function to get the focused tab info
*/
export function getFocusedTabInfo() {
    return new Promise(function (resolve, reject) {
        invokeWorkspaceAPI('getFocusedTabInfo')
            .then(focusedTab => {
                resolve(focusedTab);
            })
            .catch(() => {
                reject();
            });
    });
}

/*
description: Function to close the tab
*/
export function closeTabInConsole() {
    return new Promise(function (resolve, reject) {
        invokeWorkspaceAPI('getFocusedTabInfo')
            .then(focusedTab => {
                invokeWorkspaceAPI('closeTab', {
                    tabId: focusedTab.tabId
                })
                    .then(() => {
                        resolve();
                    })
                    .catch(() => {
                        reject();
                    });
            });
    });
}

/*
description: function to call the internal workspaceApi
*/
function invokeWorkspaceAPI(methodName, methodArgs) {
    return new Promise((resolve, reject) => {
        const apiEvent = new CustomEvent("internalapievent", {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
                category: "workspaceAPI",
                methodName: methodName,
                methodArgs: methodArgs,
                callback: (err, response) => {
                    if (err) {
                        return reject(err);
                    // eslint-disable-next-line no-else-return
                    } else {
                        return resolve(response);
                    }
                }
            }
        });
        window.dispatchEvent(apiEvent);
    });
}