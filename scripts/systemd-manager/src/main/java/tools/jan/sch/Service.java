package tools.jan.sch;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class Service {
    private final String id;
    private final String status;

    // Identity
    private String description;
    private String fragmentPath;

    // Status
    private String activeState;
    private String subState;
    private String loadState;
    private String fileState;
    private String mainPid;
    private String stateChangeTimestamp;
    private String activeEnterTimestamp;

    // Resources
    private String memoryCurrent;
    private String cpuUsageNSec;
    private String tasksCount;
    private String ipIngressBytes;
    private String ipEgressBytes;

    Service(String id, String status) {
        this.id = id;
        this.status = status;
        initialize();
    }

    public String getName() {
        String[] parts = id.split("\\.service");
        if (parts.length > 0) {
            return parts[0];
        }
        return id;
    }

    public String getId() {
        return id;
    }

    public String getStatus() {
        return status;
    }

    public String getDescription() {
        return blank(description);
    }

    public String getFragmentPath() {
        return blank(fragmentPath);
    }

    public String getActiveState() {
        return blank(activeState);
    }

    public String getSubState() {
        return blank(subState);
    }

    public String getLoadState() {
        return blank(loadState);
    }

    public String getFileState() {
        return blank(fileState);
    }

    public String getMainPid() {
        return blank(mainPid);
    }

    public String getStateChangeTimestamp() {
        return blank(stateChangeTimestamp);
    }

    public String getActiveEnterTimestamp() {
        return blank(activeEnterTimestamp);
    }

    public String getMemoryCurrent() {
        return formatBytes(memoryCurrent);
    }

    public String getCpuUsageNSec() {
        return formatNSec(cpuUsageNSec);
    }

    public String getTasksCount() {
        return blank(tasksCount);
    }

    public String getIpIngressBytes() {
        return formatBytes(ipIngressBytes);
    }

    public String getIpEgressBytes() {
        return formatBytes(ipEgressBytes);
    }

    // -------------------------------------------------------------------------

    private static String blank(String v) {
        return (v == null || v.isBlank() || v.equals("0")) ? "-" : v;
    }

    /**
     * Formats a byte count string like "18432" → "18.0 KiB", or "-" if unavailable.
     */
    private static String formatBytes(String raw) {
        if (raw == null || raw.isBlank())
            return "-";
        try {
            long bytes = Long.parseLong(raw);
            if (bytes <= 0)
                return "-";
            if (bytes < 1024)
                return bytes + " B";
            double kib = bytes / 1024.0;
            if (kib < 1024)
                return String.format("%.1f KiB", kib);
            double mib = kib / 1024.0;
            if (mib < 1024)
                return String.format("%.1f MiB", mib);
            return String.format("%.1f GiB", mib / 1024.0);
        } catch (NumberFormatException e) {
            return raw;
        }
    }

    /**
     * Formats a nanosecond value like "4200000000" → "4.2s", or "-" if unavailable.
     */
    private static String formatNSec(String raw) {
        if (raw == null || raw.isBlank())
            return "-";
        try {
            long ns = Long.parseLong(raw);
            if (ns <= 0)
                return "-";
            if (ns < 1_000_000L)
                return ns + " ns";
            double ms = ns / 1_000_000.0;
            if (ms < 1000)
                return String.format("%.1f ms", ms);
            return String.format("%.2f s", ms / 1000.0);
        } catch (NumberFormatException e) {
            return raw;
        }
    }

    public void killProcess() {
        try {
            new ProcessBuilder("systemctl", "--user", "kill", id).start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initialize() {
        try {
            Process p = new ProcessBuilder(
                    "systemctl", "--user", "show", id, "--no-pager")
                    .redirectErrorStream(true).start();

            try (BufferedReader r = new BufferedReader(
                    new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                Map<String, String> props = new HashMap<>();
                while ((line = r.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty())
                        continue;
                    int eq = line.indexOf('=');
                    if (eq == -1)
                        continue;
                    props.put(line.substring(0, eq), line.substring(eq + 1));
                }

                // Identity
                description = props.getOrDefault("Description", "");
                fragmentPath = props.getOrDefault("FragmentPath", "");

                // Status
                activeState = props.getOrDefault("ActiveState", "");
                subState = props.getOrDefault("SubState", "");
                loadState = props.getOrDefault("LoadState", "");
                fileState = props.getOrDefault("UnitFileState", "");
                mainPid = props.getOrDefault("MainPID", "");
                stateChangeTimestamp = props.getOrDefault("StateChangeTimestamp", "");
                activeEnterTimestamp = props.getOrDefault("ActiveEnterTimestamp", "");

                // Resources
                memoryCurrent = props.getOrDefault("MemoryCurrent", "");
                cpuUsageNSec = props.getOrDefault("CPUUsageNSec", "");
                tasksCount = props.getOrDefault("TasksCurrent", "");
                ipIngressBytes = props.getOrDefault("IPIngressBytes", "");
                ipEgressBytes = props.getOrDefault("IPEgressBytes", "");
            }

            p.waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String toString() {
        return getName();
    }
}
