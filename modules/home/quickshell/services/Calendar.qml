pragma Singleton

import QtQuick

QtObject {
    id: root
    
    // Current display month (0-11)
    property int displayMonth: new Date().getMonth()
    
    // Current display year
    property int displayYear: new Date().getFullYear()
    
    // Array of day objects for calendar grid
    property var calendarDays: []
    
    // Formatted month and year string
    readonly property string monthYearString: getMonthYearString()
    
    // Month names
    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    // Initialize calendar on startup
    Component.onCompleted: {
        updateCalendar();
    }
    
    // Navigate months (delta can be ±1, ±12, etc.)
    function changeMonth(delta) {
        var newMonth = displayMonth + delta;
        var newYear = displayYear;
        
        // Handle month wraparound
        while (newMonth < 0) {
            newMonth += 12;
            newYear -= 1;
        }
        while (newMonth > 11) {
            newMonth -= 12;
            newYear += 1;
        }
        
        displayMonth = newMonth;
        displayYear = newYear;
        
        updateCalendar();
    }
    
    // Reset to current month
    function resetToCurrentMonth() {
        var now = new Date();
        displayMonth = now.getMonth();
        displayYear = now.getFullYear();
        updateCalendar();
    }
    
    // Get number of days in a given month
    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }
    
    // Check if a specific date is today
    function isToday(day, month, year) {
        var now = new Date();
        return day === now.getDate() && 
               month === now.getMonth() && 
               year === now.getFullYear();
    }
    
    // Get formatted month and year string
    function getMonthYearString() {
        return monthNames[displayMonth] + " " + displayYear;
    }
    
    // Recalculate calendar grid
    function updateCalendar() {
        var days = [];
        var daysInMonth = getDaysInMonth(displayYear, displayMonth);
        var firstDayOfMonth = new Date(displayYear, displayMonth, 1).getDay();
        
        // Previous month overflow
        var prevMonth = displayMonth === 0 ? 11 : displayMonth - 1;
        var prevYear = displayMonth === 0 ? displayYear - 1 : displayYear;
        var daysInPrevMonth = getDaysInMonth(prevYear, prevMonth);
        
        // Add trailing days from previous month
        for (var i = firstDayOfMonth - 1; i >= 0; i--) {
            days.push({
                day: daysInPrevMonth - i,
                isCurrentMonth: false,
                isToday: false
            });
        }
        
        // Add days from current month
        for (var day = 1; day <= daysInMonth; day++) {
            days.push({
                day: day,
                isCurrentMonth: true,
                isToday: isToday(day, displayMonth, displayYear)
            });
        }
        
        // Add leading days from next month to fill grid (42 days = 6 rows)
        var nextMonthDays = 42 - days.length;
        for (var j = 1; j <= nextMonthDays; j++) {
            days.push({
                day: j,
                isCurrentMonth: false,
                isToday: false
            });
        }
        
        calendarDays = days;
    }
}
