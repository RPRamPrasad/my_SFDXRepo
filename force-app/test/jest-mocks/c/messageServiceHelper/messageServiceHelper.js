import { APPLICATION_SCOPE } from 'lightning/messageService';
export function handleSubscribe(message,messageType,handlerFunction){
    if(message.messageType === messageType){
        handlerFunction(message);
    }
}

export function buildMessage( messageType, data) {
    return {
            messageType: messageType,
            data: data
    };
}
export const applicationScope = {scope:APPLICATION_SCOPE};