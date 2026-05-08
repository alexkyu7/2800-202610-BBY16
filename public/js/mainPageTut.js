/**
 All methods not taught to us currently in CST;

 localStorage(): allows you to save key/value pairs in the browser.
 See https://www.w3schools.com/jsref/prop_win_localstorage.asp

 getBoundingClientRect(): returns the size of an element and its position relative to the viewport.
 See https://www.w3schools.com/jsref/met_element_getboundingclientrect.asp

 classList: returns the CSS classnames of an element. Used for toggling .active and .has-spotlight classes
 See https://www.w3schools.com/jsref/prop_element_classlist.asp

 scrollIntoView: scrolls an element into the visible area of the browser window.
 See https://www.w3schools.com/jsref/met_element_scrollintoview.asp
 */


// Each step needs:
// anchor: CSS selector of the element to spotlight (null = centred modal)
// placement: where the tooltip card appears: 'center'|'top'|'bottom'|'left'|'right'
// title: heading text shown in the card
// body: description text shown in the card

var tutorialSteps = [
    {
        elementToHighlight : null,
        tooltipPosition    : 'center',
        heading            : 'Welcome to Foodle!',
        description        : 'This quick tour will walk you through how to find food assistance near you. Click Next to get started, or skip to dive straight in.'
    },
    {
        elementToHighlight : '#tut-quick-search',
        tooltipPosition    : 'left',
        heading            : 'Quick search',
        description        : 'Enter your city or postal code, choose a service type, then hit "Find now" for instant results.'
    },
    {
        elementToHighlight : '#tut-search-btn',
        tooltipPosition    : 'bottom',
        heading            : 'Full search page',
        description        : '"Start searching" opens the full search page with filters, sorting, and detailed listings.'
    },
    {
        elementToHighlight : '#tut-map-btn',
        tooltipPosition    : 'bottom',
        heading            : 'Map view',
        description        : '"View map" plots every nearby service on an interactive map so you can see what\'s closest.'
    },
    {
        elementToHighlight : '#tut-categories',
        tooltipPosition    : 'top',
        heading            : 'Browse by category',
        description        : 'Explore food banks, meal programs, community fridges, or food recycling to find exactly what you need.'
    }
];

// DOM refs
var backdropElement = document.getElementById('tut-backdrop');
var tooltipModal = document.getElementById('tut-modal');
var tooltipArrow = document.getElementById('tut-arrow');
var stepCounterLabel = document.getElementById('tut-step-label');
var headingText = document.getElementById('tut-title');
var descriptionText = document.getElementById('tut-body');
var dotsContainer = document.getElementById('tut-dots');
var skipButton = document.getElementById('tut-skip-btn');
var backButton = document.getElementById('tut-prev-btn');
var nextButton = document.getElementById('tut-next-btn');
var restartButton = document.getElementById('tut-restart-btn');

// Spotlight is a div that sits over the highlighted element
// Its huge box shadow dims everything around it
var spotlightElement = document.createElement('div');
spotlightElement.id = 'tut-spotlight';
document.body.appendChild(spotlightElement);

// State
var currentStepIndex = 0;
var TOOLTIP_WIDTH = 320;
var SPOTLIGHT_PAD = 8;   // px of breathing room around the highlighted element
var TOOLTIP_GAP = 14;  // px gap between the spotlight edge and the tooltip card

// Build progress dots
tutorialSteps.forEach(function () {
    var dot = document.createElement('span');
    dot.className = 'tut-dot';
    dotsContainer.appendChild(dot);
});

// Show a step
function showStep(stepIndex) {
    var step   = tutorialSteps[stepIndex];
    var isLast = stepIndex === tutorialSteps.length - 1;

    // Update tooltip text and navigation controls
    stepCounterLabel.textContent = 'Step ' + (stepIndex + 1) + ' of ' + tutorialSteps.length;
    headingText.textContent = step.heading;
    descriptionText.textContent = step.description;
    backButton.style.display = stepIndex === 0 ? 'none' : '';
    nextButton.textContent = isLast ? 'Done ✓' : 'Next →';
    nextButton.classList.toggle('finish', isLast);

    // Update which dot is active
    dotsContainer.querySelectorAll('.tut-dot').forEach(function (dot, dotIndex) {
        dot.classList.toggle('active', dotIndex === stepIndex);
    });

    // Reset arrow styling before repositioning
    tooltipArrow.className = 'arrow-none';
    tooltipArrow.style.cssText = '';

    if (!step.elementToHighlight) {
        showCenteredTooltip();
    } else {
        var targetElement = document.querySelector(step.elementToHighlight);
        targetElement.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        // Brief delay so the scroll finishes before we measure the element's position
        setTimeout(function () {
            showAnchoredTooltip(targetElement, step.tooltipPosition);
        }, 80);
    }
}

// Centred tooltip
function showCenteredTooltip() {
    spotlightElement.style.display = 'none';
    backdropElement.classList.add('active');
    backdropElement.classList.remove('has-spotlight');

    tooltipModal.style.left = Math.round(window.innerWidth  / 2 - TOOLTIP_WIDTH / 2) + 'px';
    tooltipModal.style.top = Math.round(window.innerHeight / 2 - 105) + 'px';
    tooltipArrow.className = 'arrow-none';
    tooltipModal.classList.add('active');
}

/**
 * Anchors the popups next to the highlighted sections,
 *
 * Generated by Claude Sonnet 4.6
 *
 * @author https://claude.ai/
 */
// Anchored tooltip
function showAnchoredTooltip(targetElement, tooltipPosition) {
    var targetRect = targetElement.getBoundingClientRect();
    var viewportWidth = window.innerWidth;
    var viewportHeight = window.innerHeight;

    // Place the spotlight over the target element
    spotlightElement.style.display = 'block';
    spotlightElement.style.left = (targetRect.left - SPOTLIGHT_PAD) + 'px';
    spotlightElement.style.top = (targetRect.top - SPOTLIGHT_PAD) + 'px';
    spotlightElement.style.width = (targetRect.width + SPOTLIGHT_PAD * 2) + 'px';
    spotlightElement.style.height = (targetRect.height + SPOTLIGHT_PAD * 2) + 'px';

    backdropElement.classList.add('active', 'has-spotlight');

    // Flip the tooltip to the opposite side if it would go off-screen
    if (tooltipPosition === 'bottom' && targetRect.bottom + TOOLTIP_GAP + 200 > viewportHeight) tooltipPosition = 'top';
    if (tooltipPosition === 'top' && targetRect.top - TOOLTIP_GAP - 200 < 0) tooltipPosition = 'bottom';
    if (tooltipPosition === 'left' && targetRect.left - TOOLTIP_GAP - TOOLTIP_WIDTH < 0) tooltipPosition = 'right';
    if (tooltipPosition === 'right' && targetRect.right + TOOLTIP_GAP + TOOLTIP_WIDTH > viewportWidth) tooltipPosition = 'left';

    // Calculate tooltip top/left and point the arrow at the spotlighted element
    var tooltipTop, tooltipLeft;

    if (tooltipPosition === 'bottom') {
        tooltipTop = targetRect.bottom + SPOTLIGHT_PAD + TOOLTIP_GAP;
        tooltipLeft = Math.min(Math.max(targetRect.left, TOOLTIP_GAP), viewportWidth - TOOLTIP_WIDTH - TOOLTIP_GAP);
        tooltipArrow.className = 'arrow-top';
        tooltipArrow.style.left = Math.round(targetRect.left + targetRect.width / 2 - tooltipLeft - 11) + 'px';

    } else if (tooltipPosition === 'top') {
        tooltipTop = targetRect.top - SPOTLIGHT_PAD - TOOLTIP_GAP - 190;
        tooltipLeft = Math.min(Math.max(targetRect.left, TOOLTIP_GAP), viewportWidth - TOOLTIP_WIDTH - TOOLTIP_GAP);
        tooltipArrow.className = 'arrow-bottom';
        tooltipArrow.style.left = Math.round(targetRect.left + targetRect.width / 2 - tooltipLeft - 11) + 'px';
        tooltipArrow.style.bottom = '-22px';

    } else if (tooltipPosition === 'left') {
        tooltipLeft = targetRect.left - TOOLTIP_WIDTH - SPOTLIGHT_PAD - TOOLTIP_GAP;
        tooltipTop = Math.min(Math.max(targetRect.top, TOOLTIP_GAP), viewportHeight - 220);
        tooltipArrow.className = 'arrow-right';
        tooltipArrow.style.top = '22px';

    } else { // right
        tooltipLeft = targetRect.right + SPOTLIGHT_PAD + TOOLTIP_GAP;
        tooltipTop  = Math.min(Math.max(targetRect.top, TOOLTIP_GAP), viewportHeight - 220);
        tooltipArrow.className = 'arrow-left';
        tooltipArrow.style.top = '22px';
    }

    tooltipModal.style.left = Math.max(TOOLTIP_GAP, tooltipLeft) + 'px';
    tooltipModal.style.top  = Math.max(TOOLTIP_GAP, tooltipTop)  + 'px';
    tooltipModal.classList.add('active');
}

// Close the tutorial
function closeTutorial() {
    backdropElement.classList.remove('active', 'has-spotlight');
    tooltipModal.classList.remove('active');
    spotlightElement.style.display = 'none';
    localStorage.setItem('foodle_tutorial_done', '1');
}

// Button events
skipButton.addEventListener('click', closeTutorial);

backButton.addEventListener('click', function () {
    if (currentStepIndex > 0) showStep(--currentStepIndex);
});

nextButton.addEventListener('click', function () {
    if (currentStepIndex < tutorialSteps.length - 1) {
        showStep(++currentStepIndex);
    } else {
        closeTutorial();
    }
});

// Clicking the dim backdrop closes the tutorial
backdropElement.addEventListener('click', function (clickEvent) {
    if (clickEvent.target === backdropElement) closeTutorial();
});

// Restart button clears the stored flag and reloads the page
if (restartButton) {
    restartButton.addEventListener('click', function () {
        localStorage.removeItem('foodle_tutorial_done');
        location.reload();
    });
}

// Reposition the tooltip if the window is resized
var resizeDebounceTimer;
window.addEventListener('resize', function () {
    clearTimeout(resizeDebounceTimer);
    resizeDebounceTimer = setTimeout(function () { showStep(currentStepIndex); }, 120);
});

// Start
if (localStorage.getItem('foodle_tutorial_done') !== '1') {
    showStep(0);
}