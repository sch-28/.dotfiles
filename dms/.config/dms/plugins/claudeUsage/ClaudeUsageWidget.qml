import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property int fiveHour: -1
    property int weekly: -1

    component Percent: StyledText {
        property int value
        anchors.verticalCenter: parent.verticalCenter
        text: value < 0 ? "–" : value + "%"
        font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
        color: value >= 80 ? "#ff5555" : value >= 50 ? "#ffd75f" : "#ffffff"
    }

    // Token goes to curl via a config fd, never argv, so it stays out of ps.
    Process {
        id: fetch
        command: ["bash", "-c", `
            token=$(jq -r '.claudeAiOauth.accessToken // empty' ~/.claude/.credentials.json)
            curl -sf --max-time 10 --config <(printf 'header = "Authorization: Bearer %s"\\n' "$token") \\
                -H 'anthropic-beta: oauth-2025-04-20' https://api.anthropic.com/api/oauth/usage \\
            | jq -r '"\\(.five_hour.utilization | round) \\(.seven_day.utilization | round)"'
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const [five, week] = text.trim().split(" ").map(n => parseInt(n));
                root.fiveHour = isNaN(five) ? -1 : five;
                root.weekly = isNaN(week) ? -1 : week;
            }
        }
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetch.running = true
    }

    horizontalBarPill: Row {
        spacing: Theme.spacingXS

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "claude.svg"
            sourceSize: Qt.size(root.iconSize, root.iconSize)
        }

        Percent { value: root.fiveHour }
        Percent { value: root.weekly }
    }
}
