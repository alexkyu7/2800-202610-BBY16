const logo = document.getElementById("egg-logo");
const navbar = document.querySelector(".navbar");
const backdrop = document.getElementById("egg-backdrop");
const modal = document.getElementById("egg-modal");
const body = document.getElementById("egg-body");
const closeBtn = document.getElementById("egg-close-btn");
const audio = document.getElementById("egg-audio");

const messages = [
    "You’re doing great — one step at a time.",
    "Thanks for caring for your community 💚",
    "Small wins count. Keep going.",
    "You found the hidden pantry of encouragement!",
    "Need help today? You’re not alone."
];

let clickCount = 0;
let clickTimer;

function resetClicks() {
    clickCount = 0;
    clearTimeout(clickTimer);
}

function showEgg() {
    // bounce logo
    logo.classList.add("egg-bounce");
    logo.addEventListener("animationend", () => {
        logo.classList.remove("egg-bounce");
    }, { once: true });

    // navbar green flash
    navbar.classList.add("easter-egg");
    setTimeout(() => navbar.classList.remove("easter-egg"), 2500);

    // play sound
    if (audio) {
        audio.currentTime = 0;
        audio.play().catch(() => {});
    }

    // show modal
    body.textContent = messages[Math.floor(Math.random() * messages.length)];
    backdrop.classList.add("active");
    modal.classList.add("active");
}

logo.addEventListener("click", () => {
    clickCount += 1;

    if (clickCount === 1) {
        clickTimer = setTimeout(resetClicks, 1500);
    }

    if (clickCount >= 5) {
        resetClicks();
        showEgg();
    }
});

closeBtn.addEventListener("click", () => {
    backdrop.classList.remove("active");
    modal.classList.remove("active");
});

backdrop.addEventListener("click", () => {
    backdrop.classList.remove("active");
    modal.classList.remove("active");
});