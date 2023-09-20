/* eslint-disable consistent-return */
import { LightningElement, api } from "lwc";
import 'c/checkBrowser';
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CONFETTI from "@salesforce/resourceUrl/confetti";


export default class ConfettiComponent extends LightningElement {
    myconfetti;

    connectedCallback() {
        Promise.all([
            loadScript(this, CONFETTI)
        ])
            .then(() => {
                this.setUpCanvas();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }


    setUpCanvas() {
        let confettiCanvas = this.template.querySelector("canvas.confettiCanvas");
        // eslint-disable-next-line no-undef
        this.myconfetti = confetti.create(confettiCanvas, { resize: true });
    }

    @api showConfetti() {
        let randomNum = this.randomFun(0, 7);
        switch (randomNum) {
            case 0:
                this.basicCannon();
                break;
            case 1:
                this.fireworks();
                break;
            case 2:
                this.shower();
                break;
            case 3:
                this.schoolpride();
                break;
            case 4:
                this.celebration();
                break;
            case 5:
                this.snow();
                break;
            case 6:
                this.burst();
                break;
            case 7:
                this.randomCannon();
                break;
            default:
                this.fireworks();
        }
    }

    randomFun(min, max) {
        return Math.floor(Math.random() * (max - min) + min);
    }

    basicCannon() {
        // eslint-disable-next-line no-undef
        confetti({
            particleCount: 100,
            spread: 70,
            origin: {
                y: 0.6
            }
        });
    }


    randomCannon() {
        // eslint-disable-next-line no-undef
        confetti({
            angle: this.randomFun(55, 125),
            spread: this.randomFun(50, 70),
            particleCount: this.randomFun(50, 100),
            origin: {
                y: 0.6
            }
        });
    }


    fireworks() {
        let end = Date.now() + 15 * 200;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                startVelocity: 30,
                spread: 360,
                ticks: 60,
                origin: {
                    x: Math.random(),
                    // since they fall down, start a bit higher than random
                    y: Math.random() - 0.2
                }
            });
        }, 200);
    }

    schoolpride() {
        let end = Date.now() + 15 * 200;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 2,
                angle: 60,
                spread: 55,
                origin: { x: 0 },
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 2,
                angle: 121,
                spread: 55,
                origin: { x: 1 },
            });
        }, 10);
    }

    shower() {
        let end = Date.now() + (15 * 100);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 10,
                startVelocity: 0,
                ticks: 300,
                origin: {
                    x: Math.random(),
                    y: 0
                },
            });
        }, 10);
    }

    // Method for celebration confetti mode
    celebration() {
        let end = Date.now() + (15 * 100);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 10,
                angle: 60,
                spread: 25,
                origin: {
                    x: 0,
                    y: 0.65
                },
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 10,
                angle: 120,
                spread: 25,
                origin: {
                    x: 1,
                    y: 0.65
                },
            });
        }, 10);
    }

    // Method for burst confetti mode
    burst() {
        let end = Date.now() + (15 * 75);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            if (Date.now() > end) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 7,
                startVelocity: 25,
                angle: 335,
                spread: 10,
                origin: {
                    x: 0,
                    y: 0,
                },
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 7,
                startVelocity: 25,
                angle: 205,
                spread: 10,
                origin: {
                    x: 1,
                    y: 0,
                },
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 7,
                startVelocity: 35,
                angle: 140,
                spread: 30,
                origin: {
                    x: 1,
                    y: 1,
                },
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 7,
                startVelocity: 35,
                angle: 40,
                spread: 30,
                origin: {
                    x: 0,
                    y: 1,
                },
            });
        }, 10);
    }

    snow() {
        let duration = 15 * 1000;
        let animationEnd = Date.now() + duration;
        let skew = 1;

        function randomInRange(min, max) {
            return Math.random() * (max - min) + min;
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        let interval = setInterval(function () {
            // eslint-disable-next-line no-undef
            let timeLeft = animationEnd - Date.now();

            if (timeLeft <= 0) {
                return clearInterval(interval);
            }

            // eslint-disable-next-line no-undef
            let ticks = Math.max(200, 500 * (timeLeft / duration));
            skew = Math.max(0.8, skew - 0.001);

            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 1,
                startVelocity: 0,
                ticks: ticks,
                gravity: 0.5,
                origin: {
                    x: Math.random(),
                    // since particles fall down, skew start toward the top
                    y: (Math.random() * skew) - 0.2
                },
                shapes: ['circle'],
                scalar: randomInRange(0.4, 1)
            });
        }, 10);
    }
}