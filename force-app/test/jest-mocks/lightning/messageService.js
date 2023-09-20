class MessageService {
    subscribers = {};

    publish = (messageContext, messageChannel, message) => {
        const item = this.subscribers[messageContext.toString()];

        if (item) {
            item.filter(element => element.messageChannel === messageChannel)
                .forEach(element => {
                    element.listener(message);
            });
        }
    };

    subscribe = (messageContext, messageChannel, listener, subscriberOptions) => {
        this.subscribers[messageContext.toString()] = [];
        const subscriber = {
            messageChannel: messageChannel,
            listener: listener,
            subscriberOptions: subscriberOptions
        };

        this.subscribers[messageContext.toString()].push(subscriber);

        return this.subscriber;
    };

    releaseMessageContext = (messageContext) => {
        subscribers[messageContext.toString()] = undefined;
    }
}

const messageService = new MessageService();

export const publish = jest.fn().mockImplementation((messageContext, messageChannel, message) => {
    messageService.publish(messageContext, messageChannel, message);
});

export const subscribe = jest.fn().mockImplementation((messageContext, messageChannel, listener, subscriberOptions) => {
    messageService.subscribe(messageContext, messageChannel, listener, subscriberOptions);
});

export const releaseMessageContext = jest.fn().mockImplementation((messageContext) => {
    messageService.releaseMessageContext(messageContext);
});

export const APPLICATION_SCOPE = 'APPLICATION SCOPE';

export const createMessageContext = jest.fn();

export const MessageContext = jest.fn().mockReturnValue('MESSAGE CONTEXT');