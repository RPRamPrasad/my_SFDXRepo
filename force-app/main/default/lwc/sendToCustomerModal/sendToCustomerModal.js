
import { LightningElement,api } from 'lwc';

export default class SendToCustomerModal extends LightningElement {

    @api customerName;
    @api customerEmail;
    showEmptyEmailError=false;
    @api isModalOpen;

        connectedCallback()
        {

            if(this.customerEmail==null)
            {
                this.showEmptyEmailError=true;

            }
            else{
                this.showEmptyEmailError=false;
            }


        }

        closeModal() {

            this.isModalOpen = false;
            const passEvent = new CustomEvent('closemodal', {
                detail:{showModal:false}
            });
           this.dispatchEvent(passEvent);
        }

        handleSend(){
            this.isModalOpen = false;
            const sendEvent = new CustomEvent('sendconfirmation', {
                    detail:{sendEmail:true,
                            userEmail:this.customerEmail
                    }
                });
            this.dispatchEvent(sendEvent);

        }

        handleEmailChange(event){
            this.customerEmail = event.target.value;

            if(this.customerEmail==='')
            {
                this.showEmptyEmailError=true;
            }
            else{
                this.showEmptyEmailError=false;
            }


        }

}