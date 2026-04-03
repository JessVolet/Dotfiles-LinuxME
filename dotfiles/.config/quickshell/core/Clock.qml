// ╔══════════════════════════════════════════════════════════════╗
// ║  Clock.qml — Consolidated Time Provider Singleton          ║
// ║  CORE — DO NOT MODIFY (managed by dotfiles installer)      ║
// ║                                                            ║
// ║  ONE timer for the entire shell. All plugins read from     ║
// ║  Core.Clock instead of creating their own Date()/Timer.    ║
// ║  This alone saves significant CPU on low-power devices.    ║
// ╚══════════════════════════════════════════════════════════════╝
pragma Singleton
import QtQuick

QtObject {
    id: clock

    // ── Formatted strings (read-only for plugins) ──
    readonly property string time24: _time24
    readonly property string time12: _time12
    readonly property string timeSeconds: _timeSeconds
    readonly property string dateShort: _dateShort
    readonly property string dateFull: _dateFull
    readonly property string dayName: _dayName

    // ── Raw values (for math/logic in plugins) ──
    readonly property int hours: _hours
    readonly property int minutes: _minutes
    readonly property int seconds: _seconds
    readonly property int dayOfWeek: _dayOfWeek

    // ── Internal state ──
    property string _time24: "00:00"
    property string _time12: "12:00 AM"
    property string _timeSeconds: "00:00:00"
    property string _dateShort: ""
    property string _dateFull: ""
    property string _dayName: ""
    property int _hours: 0
    property int _minutes: 0
    property int _seconds: 0
    property int _dayOfWeek: 0

    // ── The ONE timer ──
    property Timer _ticker: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            clock._hours = now.getHours()
            clock._minutes = now.getMinutes()
            clock._seconds = now.getSeconds()
            clock._dayOfWeek = now.getDay()

            clock._time24 = Qt.formatTime(now, "hh:mm")
            clock._time12 = Qt.formatTime(now, "h:mm AP")
            clock._timeSeconds = Qt.formatTime(now, "hh:mm:ss")
            clock._dateShort = Qt.formatDate(now, "ddd, dd MMM")
            clock._dateFull = Qt.formatDate(now, "dddd, MMMM d, yyyy")
            clock._dayName = Qt.formatDate(now, "dddd")
        }
    }
}
