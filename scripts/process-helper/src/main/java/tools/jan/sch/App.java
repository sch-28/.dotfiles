package com.mycompany.app;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.jline.reader.Candidate;
import org.jline.reader.Completer;
import org.jline.reader.EndOfFileException;
import org.jline.reader.LineReader;
import org.jline.reader.LineReaderBuilder;
import org.jline.reader.ParsedLine;
import org.jline.reader.UserInterruptException;
import org.jline.reader.LineReader.Option;
import org.jline.reader.impl.completer.ArgumentCompleter;
import org.jline.reader.impl.completer.StringsCompleter;
import org.jline.terminal.Terminal;
import org.jline.terminal.TerminalBuilder;

/**
 * Hello world!
 */
public class App {

    static Process getRoot(ProcessHandle ph) {
        String cmd = ph.info().command().orElse(null);
        if (cmd == null)
            return new Process(ph);

        ProcessHandle current = ph;
        int iter = 0;
        while (true) {
            ProcessHandle parent = current.parent().orElse(null);
            if (parent == null)
                break;

            String parentCmd = parent.info().command().orElse(null);
            if (parentCmd == null || !parentCmd.equals(cmd))
                break;
            current = parent;

            iter++;
            if (iter > 50)
                break;
        }

        return new Process(current);

    }

    static Collection<Process> getProcesses() {

        Map<Long, Process> roots = ProcessHandle.allProcesses()
                .filter(ph -> ph.info().command().isPresent())
                .map(App::getRoot)
                .collect(Collectors.toMap(Process::pid, ph -> ph, (a, b) -> a));

        return roots.values();

    }

    public static void main(String[] args) {
        try {

            Terminal terminal = TerminalBuilder.builder().system(true).build();

            Collection<Process> processes = getProcesses();

            Completer completer = new ArgumentCompleter(
                    new StringsCompleter("kill", "inspect", "quit"),
                    (LineReader reader, ParsedLine line, List<Candidate> candidates) -> {
                        for (Process ph : processes) {
                            String name = ph.getName();
                            if (name != null)
                                candidates.add(new Candidate(name));
                        }

                    });

            LineReader reader = LineReaderBuilder.builder().terminal(terminal).completer(completer).build();
            reader.option(Option.AUTO_MENU, true);
            reader.option(Option.MENU_COMPLETE, true);

            while (true) {
                String input = reader.readLine("process helper> ").trim();
                if (input.equals("quit"))
                    break;

                String[] parsedInput = input.split("\\s",2);
                if (parsedInput.length < 2) {
                    System.out.println("Invalid input. Usage: <option> <command>");
                    continue;
                }
                String option = parsedInput[0];
                String command = parsedInput[1];


                Process selected = null;
                for (Process ph : processes) {
                    String cmd = ph.command().orElse(null);
                    if (cmd != null && cmd.contains(command)) {
                        selected = ph;
                        break;
                    }
                }

                if (selected == null) {
                    System.out.println("No process found matching: " + command);
                    continue;
                }

                if (option.equals("kill")) {
                    selected.raw().destroyForcibly();
                    break;
                }

                if (option.equals("inspect")) {
                    selected.info();
                }
            }

        } catch (UserInterruptException e) {
            return; 
        } catch (EndOfFileException e) {
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
