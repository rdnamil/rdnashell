/*-------------------------------------
--- Weather.qml - widgets by andrel ---
-------------------------------------*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style
import "../globals.js" as Globals

Ctrl.Widget { id: root
	onClicked: popout.toggle();
	tooltip: `${Service.Weather.location?.city || ''}, ${Service.Weather.location?.region || ''}`
	icon: Item {
		width: childrenRect.width -temp.anchors.rightMargin
		height: childrenRect.height -temp.anchors.bottomMargin

		IconImage { id: iconImage
			implicitSize: Globals.Controls.iconSize
			source: Service.Weather.getIcon();
			opacity: 0.6
			layer.enabled: true
			layer.effect: OpacityMask { maskSource: Item {
				width: iconImage.width; height: iconImage.height;

				Text {
					visible: temp.visible
					x: temp.x; y: temp.y;
					text: temp.text
					style: Text.Outline
					font.pointSize: 8
					font.weight: 800
				}
			} invert: true; }
		}

		Item {
			anchors.fill: iconImage

			Text { id: temp
				visible: Service.Weather.forecast
				anchors {
					right: parent.right
					rightMargin: -Globals.Controls.padding *1.5
					bottom: parent.bottom
					bottomMargin: -Globals.Controls.spacing
				}
				text: `${parseInt(Service.Weather.forecast?.current.temperature_2m)}${Service.Weather.forecast?.current_units.temperature_2m}`
				color: Globals.Colours.text
				font.pointSize: 8
			}
		}
	}

	Ctrl.Popout { id: popout
		function getLocalTime(time, offset = parseInt(Service.Weather.location?.offset *1000 || '0')) {
			let localTime = new Date(time);
			localTime = new Date(localTime.getTime() +offset);

			return Qt.formatDateTime(localTime, "h:mm");
		}

		content: Style.PageLayout { id: content
			readonly property var daily: Service.Weather.forecast?.daily || null

			header: Item {
				width: content.body.width
				height: refresh.height +Globals.Controls.spacing *2

				Row {
					anchors {
						left: parent.left; leftMargin: (parent.height -height) /2;
						verticalCenter: parent.verticalCenter
					}
					spacing: Globals.Controls.spacing

					IconImage {
						implicitSize: currentLocation.height
						source: Quickshell.iconPath("mark-location")
					}

					Text { id: currentLocation
						anchors.verticalCenter: parent.verticalCenter
						text: `<b>${Service.Weather.location?.city || ''}</b>, ${Service.Weather.location?.regionName || ''}`
						color: Globals.Colours.text
						font.pointSize: 10
					}
				}

				Ctrl.Button { id: refresh
					enabled: !Service.Weather.running
					onClicked: if (enabled) Service.Weather.getWeatherFrom();
					anchors {
						right: parent.right; rightMargin: (parent.height -height) /2;
						verticalCenter: parent.verticalCenter
					}
					icon: IconImage {
						implicitSize: Globals.Controls.iconSize
						source: Quickshell.iconPath("view-refresh")
					}
				}
			}
			body: Item {
				width: layout.width; height: layout.height;

				Rectangle {
					x: current.x -(width -current.width) /2; y: current.y -(height -current.height) /2;
					width: current.width +Globals.Controls.padding; height: current.height +Globals.Controls.padding;
					radius: 6
					color: Globals.Colours.base
				}

				Row {  id: layout
					padding: Globals.Controls.padding
					spacing: Globals.Controls.padding

					Column { id: current
						spacing: Globals.Controls.spacing

						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: Qt.formatDateTime(content.daily?.time[0] || "2026-01-01", "dddd")
							color: Globals.Colours.text
							font.pointSize: 10
							font.letterSpacing: 1.0
							font.weight: 700
						}

						Rectangle {
							anchors.horizontalCenter: parent.horizontalCenter
							width: parent.width -Globals.Controls.padding; height: 1
							color: Globals.Colours.light
							opacity: 0.4
						}

						Row {
							anchors.horizontalCenter: parent.horizontalCenter
							spacing: Globals.Controls.spacing

							IconImage {
								implicitSize: currentWeather.height
								source: Service.Weather.getIcon()
							}

							Text { id: currentWeather
								text: switch (Service.Weather.forecast?.current.weather_code || 0) {
									case 0: return "Clear sky";
									case 1: return "Mainly clear";
									case 2: return "Partly cloudy";
									case 3: return "Overcast";
									case 45: case 48: return "Fog";
									case 51: return "Light drizzle";
									case 23: return "Moderate drizzle";
									case 55: return "Dense drizzle";
									case 56: return "Light freezing drizzle";
									case 57: return "Dense freezing drizzle";
									case 61: return "Slight rain";
									case 63: return "Moderate rain";
									case 65: return "Heavy rain";
									case 71: return "Slight snow fall";
									case 73: return "Moderate snow fall";
									case 75: return "Heavy snow fall";
									case 77: return "Snow grains";
									case 80: return "Slight rain showers";
									case 81: return "Moderate rain showers";
									case 82: return "Violent rain showers";
									case 85: return "Slight snow showers";
									case 86: return "Heavy snow showers";
									case 95: return "Thunderstorm";
									case 96: return "Thunderstorm with slight hail";
									case 99: return "Thunderstorm with heavy hail";
								}
								color: Globals.Colours.text
								font.pointSize: 8
								font.weight: 600
							}
						}

						Row {
							anchors.horizontalCenter: parent.horizontalCenter
							spacing: Globals.Controls.spacing

							IconImage {
								visible: false
								anchors.verticalCenter: parent.verticalCenter
								implicitSize: parent.height
								source: Quickshell.iconPath("sensors-temperature-symbolic")
							}

							Text { id: currentTemp
								anchors.verticalCenter: parent.verticalCenter
								text: temp.text
								color: Globals.Colours.text
								font.pointSize: 16
								font.weight: 600
							}

							Column {
								Text {
									text: `${parseInt(content.daily?.temperature_2m_min[0] || 0) > 0? '+' : ''}${parseInt(content.daily?.temperature_2m_min[0] || 0)}${Service.Weather.forecast?.daily_units.temperature_2m_min || ''}`
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 300
								}

								Text {
									text: `${parseInt(content.daily?.temperature_2m_max[0] || 0) > 0? '+' : ''}${parseInt(content.daily?.temperature_2m_max[0] || 0)}${Service.Weather.forecast?.daily_units.temperature_2m_max || ''}`
									color: Globals.Colours.text
									font.pointSize: 8
									font.weight: 600
								}
							}
						}
					}

					Item { width: 1; height: width; }

					Repeater {
						model: 5
						delegate: Column { id: delegate
							required property int index

							spacing: Globals.Controls.spacing

							Text {
								anchors.horizontalCenter: parent.horizontalCenter
								text: Qt.formatDateTime(content.daily?.time[delegate.index +1] || "2026-01-01", "ddd")
								color: Globals.Colours.text
								font.pointSize: 10
							}

							IconImage {
								anchors.horizontalCenter: parent.horizontalCenter
								implicitSize: 28
								source: Service.Weather.getIcon(content.daily?.weather_code[delegate.index +1] || 0, true)
							}

							Text {
								anchors.horizontalCenter: parent.horizontalCenter
								bottomPadding: -delegate.spacing
								text: `${parseInt(content.daily?.temperature_2m_min[delegate.index +1] || 0) > 0? '+' : ''}${parseInt(content.daily?.temperature_2m_min[delegate.index +1] || 0)}${Service.Weather.forecast?.daily_units.temperature_2m_min || ''}`
								color: Globals.Colours.text
								font.pointSize: 6
								font.letterSpacing: 0.5
							}

							Text {
								anchors.horizontalCenter: parent.horizontalCenter
								bottomPadding: -delegate.spacing
								text: `${parseInt(content.daily?.temperature_2m_max[delegate.index +1] || 0) > 0? '+' : ''}${parseInt(content.daily?.temperature_2m_max[delegate.index +1]) || 0}${Service.Weather.forecast?.daily_units.temperature_2m_max || ''}`
								color: Globals.Colours.text
								font.pointSize: 6
								font.letterSpacing: 0.5
								font.weight: 800
							}
						}
					}
				}
			}
		}
	}
}
