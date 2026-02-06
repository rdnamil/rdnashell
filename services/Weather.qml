/*--------------------------------------
--- Weather.qml - services by andrel ---
--------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property var forecast: null
	property string location: ''

	function getIcon(weatherCode = root.forecast?.current.weather_code, isDay = root.forecast?.current.is_day) {
		let i = "app";

		switch (weatherCode) {
			case 0: case 1:
				if (isDay === 1) i =  "clear";
				else i =  "clear-night";
				break;
			case 2:
				if (isDay === 1) i = "few-clouds";
				else i = "few-clouds-night";
				break;
			case 3:
				i = "overcast";
				break;
			case 45: case 48:
				i = "fog";
				break;
			case 51: case 53: case 55: case 56: case 57:
				i = "showers-scattered";
				break;
			case 61: case 63: case 65: case 66: case 67: case 80: case 81: case 82:
				i = "showers";
				break;
			case 71: case 73: case 75: case 77: case 85: case 86:
				i = "snow";
				break;
			case 95: case 96: case 99:
				i = "storm";
				break;
			default:
				i = "app";
		}

		return Quickshell.iconPath(`weather-${i}`, true)
	}

	function getWeatherFrom(lon, lat) {
		getWeather.exec(["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&daily=sunrise,sunset,weather_code,temperature_2m_max,temperature_2m_min&current=weather_code,temperature_2m,is_day`]);
	}

	Process { id: getLocation
		running: true
		command: ["sh", "-c", 'curl "http://ip-api.com/json?fields=lat,lon,city,region"']
		stdout: StdioCollector {
			onStreamFinished: {
				const l = JSON.parse(text);
				root.getWeatherFrom(l.lon, l.lat);
				root.location = `${l.city}, ${l.region}`;
			}
		}
	}

	Process { id: getWeather
		stdout: StdioCollector {
			onStreamFinished: root.forecast = JSON.parse(text);
		}
	}

	Timer {
		running: true
		repeat: true
		interval: 36e5
		onTriggered: getLocation.running = true
	}

	IpcHandler {
		target: "weather"
		function update(): void { getWeather.running = true; }
	}
}
