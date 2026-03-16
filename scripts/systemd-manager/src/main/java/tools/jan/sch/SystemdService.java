package tools.jan.sch;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class SystemdService {
    public List<Service> services;

    private List<Service> getServices() {
        try {
            ArrayList<Service> newServices = new ArrayList<>();
            Process p = new ProcessBuilder("systemctl",
                    "--user",
                    "list-unit-files",
                    "--type=service",
                    "--no-legend",
                    "--no-pager").redirectErrorStream(true).start();

            try (BufferedReader r = new BufferedReader(
                    new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = r.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty())
                        continue;

                    String[] parts = line.split("\\s+");
                    if (parts.length < 2)
                        continue;
                    String id = parts[0];
                    if(id.contains("@.service")) continue;
                    String status = parts[1];
                    newServices.add(new Service(id, status));
                }
            }
            int code = p.waitFor();
            if (code != 0) {
                throw new RuntimeException("systemctl error " + code);
            }

            return newServices;

        } catch (Exception e) {
            throw new RuntimeException("Failed to get systemd services", e);

        }
    }

    public SystemdService() {

        this.services = getServices();
    }

}
