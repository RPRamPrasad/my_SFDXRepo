import { LightningElement, api } from 'lwc';
export default class Modal extends LightningElement {
    @api showModal = false;
    @api backdropModal = false;
    @api header;
    @api modalWidth;
    @api modalScroll;

    @api show = jest.fn();

    @api hide = jest.fn();
}