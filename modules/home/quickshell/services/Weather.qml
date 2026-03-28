import QtQuick
import Quickshell
import qs
pragma Singleton

QtObject {
    id: root

    property string latitude: Preferences.weatherLat
    property string longitude: Preferences.weatherLong
    property var currentWeather: null
    property var dailyForecast: null
    property bool loading: false
    property string error: ""
    // derived properties for easy access
    property string temperature: currentWeather ? Math.round(currentWeather.temperature) + "°" : "--"
    property int weatherCode: currentWeather ? currentWeather.weathercode : -1
    property bool isDay: currentWeather ? currentWeather.is_day === 1 : true
    // Auto-refresh every 30 minutes
    property Timer autoRefreshTimer
    property Timer fetchDebounce
    property var searchResults: []
    property bool searchLoading: false

    function searchLocation(query) {
        if (!query || query.length < 2) {
            searchResults = [];
            return ;
        }
        searchLoading = true;
        var xhr = new XMLHttpRequest();
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(query) + "&count=5&language=en&format=json";
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                searchLoading = false;
                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        root.searchResults = json.results || [];
                    } catch (e) {
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function fetchWeather() {
        if (!latitude || !longitude)
            return ;

        loading = true;
        error = "";
        // Fetch Weather
        var xhr = new XMLHttpRequest();
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude + "&current_weather=true&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto";
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false;
                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        root.currentWeather = json.current_weather;
                        root.dailyForecast = json.daily;
                    } catch (e) {
                        root.error = "Parse Error";
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
        // Fetch Location Name (Reverse Geocoding)
        var geoXhr = new XMLHttpRequest();
        // Using Nominatim (OpenStreetMap) Geocoding API
        var geoUrl = "https://nominatim.openstreetmap.org/reverse?lat=" + latitude + "&lon=" + longitude + "&format=json";
        geoXhr.onreadystatechange = function() {
            if (geoXhr.readyState === XMLHttpRequest.DONE) {
                if (geoXhr.status === 200) {
                    try {
                        var json = JSON.parse(geoXhr.responseText);
                        if (json.address) {
                            var addr = json.address;
                            // Prefer city, then town, then village, then suburb
                            var name = addr.city || addr.town || addr.village || addr.suburb || addr.municipality || "Unknown Location";
                            if (name && name !== "Unknown Location")
                                Preferences.weatherLocationName = name;

                        }
                    } catch (e) {
                    }
                }
            }
        };
        geoXhr.open("GET", geoUrl);
        // Nominatim requires a SystemInfo-Agent
        geoXhr.setRequestHeader("SystemInfo-Agent", "AntigravQs/1.0");
        geoXhr.send();
    }

    // Refresh when location changes
    onLatitudeChanged: fetchDebounce.restart()
    onLongitudeChanged: fetchDebounce.restart()
    Component.onCompleted: fetchWeather()

    autoRefreshTimer: Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }

    fetchDebounce: Timer {
        id: fetchDebounce

        interval: 1000
        repeat: false
        onTriggered: root.fetchWeather()
    }

}
