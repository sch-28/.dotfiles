package com.mycompany.app;

import java.nio.file.Path;
import java.util.Optional;

public class Process {

    private final ProcessHandle ph;

    public Process(ProcessHandle ph) {
        this.ph = ph;
    }

    public ProcessHandle raw() {
        return ph;
    }

    public long pid() {
        return ph.pid();
    }

    public Optional<String> command() {
        return ph.info().command();
    }

    public void info() {
        System.out.println("PID: " + ph.pid());
        System.out.println("Command: " + command().orElse(null));
        System.out.println("Arguments: " + String.join(" ", ph.info().arguments().orElse(new String[] {})));
        System.out.println("Start time: " + ph.info().startInstant().orElse(null));
        System.out.println("CPU duration: " + ph.info().totalCpuDuration().orElse(null));
    }

    public String getName() {
        return command()
                .map(Path::of)
                .map(Path::getFileName)
                .map(Path::toString)
                .orElse("<unknown>");
    }

}
