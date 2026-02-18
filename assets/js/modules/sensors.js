/**
 * SOS EXPERIMENTAL MODULE: SENSORS
 * Access Compass/Gyro for Tactical HUD.
 */

const Sensors = {
    heading: 0,
    pitch: 0,
    roll: 0,

    init: () => {
        console.log(">>> Sensors Module Loaded");
        window.addEventListener('deviceorientation', Sensors.handleOrientation);
    },

    handleOrientation: (event) => {
        // iOS requires permission, Android usually just works (or needs secure context)
        Sensors.heading = event.webkitCompassHeading || (360 - event.alpha);
        Sensors.pitch = event.beta;
        Sensors.roll = event.gamma;

        // Update Radar HUD if it exists
        const compassEl = document.getElementById('hud-compass');
        if (compassEl) {
            compassEl.style.transform = `rotate(-${Sensors.heading}deg)`;
            document.getElementById('hud-heading-val').innerText = Math.round(Sensors.heading) + "°";
        }
    },

    requestPermission: async () => {
        if (typeof DeviceOrientationEvent.requestPermission === 'function') {
            try {
                const response = await DeviceOrientationEvent.requestPermission();
                if (response === 'granted') {
                    window.addEventListener('deviceorientation', Sensors.handleOrientation);
                }
            } catch (e) {
                console.error(e);
            }
        }
    }
};
