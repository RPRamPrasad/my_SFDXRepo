import { LightningElement, api } from 'lwc';

import { PERSONAL_ARTICLES_ITEM_SCHEDULE_COLUMNS } from './columns';

export default class PolicyDetailsPapSchedule extends LightningElement {

    ERRMSG_DEFAULT = "No personal articles listed for this term.";
    ERRMSG_FUTURETERM = "Potential data shown in future term.";
    ERRMSG_PASTTERM = "Historical information is not available.";
    
    @api details;
    @api renewalDate;

    columns = PERSONAL_ARTICLES_ITEM_SCHEDULE_COLUMNS;
    personalArticles = [];

    papScheduleErrored = false;
    papScheduleMessage;

    get personalArticlesCountStr () {
        if(this.papScheduleErrored) {
            return "";
        }
        
        return ` (${this.personalArticles.length})`;
    }

    connectedCallback() {
        this.buildItemSchedule();
    }

    buildItemSchedule() {
        const details = this.details;

        if(details?.termVersion?.insurableRisk?.length && details?.termVersion?.insurableRisk[0].personalArticle?.length) {
            details.termVersion.insurableRisk[0].personalArticle.forEach(personalArticle => {
                this.personalArticles.push(
                    Object.assign({
                        classificationNameAndCd: `${personalArticle.classificationName} - ${personalArticle.classificationCode}`
                    }, personalArticle)
                );
            });

            this.personalArticles.sort((a, b) => {
                return a.classificationNameAndCd.localeCompare(b.classificationNameAndCd) || b.statedValueAmount - a.statedValueAmount;
            });

        }
        else {
            // Check dates
            // Case 1, we see a renewal date already advanced, recommend going to future term
            // Case 2, we see we are in a prior term outside of current date, prompt to try current date
            // Case 3, show default "No personal articles listed for this term" message
            const currentDate = new Date();
            const termStartDate = new Date(this.details.termVersion.fullTermStartDate);
            const termEndDate = new Date(this.details.termVersion.fullTermEndDate);
            const renewalDate = new Date(this.renewalDate.substring(0, 10) + "T00:00:00.000Z");

            this.papScheduleMessage = this.ERRMSG_DEFAULT;

            if(termStartDate <= currentDate && currentDate <= termEndDate && termEndDate < renewalDate) {
                this.papScheduleMessage += ` ${this.ERRMSG_FUTURETERM}`;
            }
            else if (termEndDate <= currentDate) {
                this.papScheduleMessage += ` ${this.ERRMSG_PASTTERM}`;
            }

            this.papScheduleErrored = true;
        }
    }
}