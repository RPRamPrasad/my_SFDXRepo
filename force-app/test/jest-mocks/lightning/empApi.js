// An object to store callbacks
const _channels = {};

// On subscribe, store the callback function and resolve the promise
export const subscribe = jest.fn((channel, replayId, onMessageCallback) => {
    _channels[channel] = { onMessageCallback };
    Promise.resolve({
        id: "_" + Date.now(),
        channel: channel,
        replayId: replayId
    });
});

// I'm using isEmpEnabled in my component, so I have it set to return true
export const isEmpEnabled = jest.fn();

// A Jest-specific function for "publishing" your Platform Event
export const jestMockPublish = jest.fn((channel, message) => {
    if (
        _channels[channel] &&
        _channels[channel].onMessageCallback instanceof Function
    ) {
        _channels[channel].onMessageCallback(message);
    }
    Promise.resolve(true);
});

// I just copied these from the standard lightning/empApi stub
export const unsubscribe = jest.fn().mockResolvedValue({});
export const onError = jest.fn().mockResolvedValue(jest.fn());
export const setDebugFlag = jest.fn().mockResolvedValue();