export const FlowNavigationFinishEventName = 'lightning__flowattributefinish';

export class FlowNavigationFinishEvent extends CustomEvent {
 constructor(attributeName, attributeValue) {
    super(FlowNavigationFinishEventName, {
        composed: true,
        cancelable: true,
        bubbles: true,
        detail: {
            attributeName,
            attributeValue
        }
    });
  }
}

