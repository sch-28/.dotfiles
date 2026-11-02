import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    component Percent: StyledText {
        property int value
        anchors.verticalCenter: parent.verticalCenter
        text: value < 0 ? "–" : value + "%"
        font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
        color: value >= 80 ? "#ff5555" : value >= 50 ? "#ffd75f" : "#ffffff"
    }

    component Usage: Row {
        id: usage
        property string configDir
        property int fiveHour: -1
        property int weekly: -1

        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXS

        // Token goes to curl via a config fd, never argv, so it stays out of ps.
        Process {
            id: fetch
            command: ["bash", "-c", `
                token=$(jq -r '.claudeAiOauth.accessToken // empty' "$1/.credentials.json")
                curl -sf --max-time 10 --config <(printf 'header = "Authorization: Bearer %s"\\n' "$token") \\
                    -H 'anthropic-beta: oauth-2025-04-20' https://api.anthropic.com/api/oauth/usage \\
                | jq -r '"\\(.five_hour.utilization | round) \\(.seven_day.utilization | round)"'
            `, "_", usage.configDir]
            stdout: StdioCollector {
                onStreamFinished: {
                    const [five, week] = text.trim().split(" ").map(n => parseInt(n));
                    usage.fiveHour = isNaN(five) ? -1 : five;
                    usage.weekly = isNaN(week) ? -1 : week;
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

        Percent { value: usage.fiveHour }
        Percent { value: usage.weekly }
    }

    horizontalBarPill: Row {
        spacing: Theme.spacingXS

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "claude.svg"
            sourceSize: Qt.size(root.iconSize, root.iconSize)
        }

        Usage { configDir: Quickshell.env("HOME") + "/.claude" }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: "│"
            font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
            color: "#888888"
        }

        Usage { configDir: Quickshell.env("HOME") + "/.claude-personal" }
    }
}
