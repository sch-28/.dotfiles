package tools.jan.sch;

import java.io.IOException;
import java.util.List;

import com.googlecode.lanterna.TerminalSize;
import com.googlecode.lanterna.TextColor;
import com.googlecode.lanterna.gui2.*;
import com.googlecode.lanterna.gui2.dialogs.MessageDialog;
import com.googlecode.lanterna.gui2.dialogs.MessageDialogButton;
import com.googlecode.lanterna.screen.Screen;
import com.googlecode.lanterna.terminal.DefaultTerminalFactory;

public class App {

    // -------------------------------------------------------------------------
    // Detail labels (updated on every selection change)
    // -------------------------------------------------------------------------

    private static ComboBox<Service> serviceSelect = new ComboBox<>();
    // Identity
    private static Label valId = new Label("");
    private static Label valDescription = new Label("");
    private static Label valPath = new Label("");

    // Status
    private static Label valActiveState = new Label("");
    private static Label valSubState = new Label("");
    private static Label valLoadState = new Label("");
    private static Label valFileState = new Label("");
    private static Label valMainPid = new Label("");
    private static Button killButton = new Button("Kill", () -> {
        Service selected = serviceSelect.getSelectedItem();
        selected.killProcess();
    });
    private static Label valActiveSince = new Label("");
    private static Label valStateChanged = new Label("");

    // Resources
    private static Label valMemory = new Label("");
    private static Label valCpu = new Label("");
    private static Label valTasks = new Label("");
    private static Label valIngress = new Label("");
    private static Label valEgress = new Label("");

    // -------------------------------------------------------------------------

    public static void main(String[] args) {
        DefaultTerminalFactory terminalFactory = new DefaultTerminalFactory();
        Screen screen = null;

        try {
            screen = terminalFactory.createScreen();
            screen.startScreen();

            final WindowBasedTextGUI textGUI = new MultiWindowTextGUI(screen);
            final Window window = new BasicWindow("Systemd Service Manager");
            window.setHints(java.util.Arrays.asList(Window.Hint.FULL_SCREEN));

            // ── Root panel ────────────────────────────────────────────────────
            Panel root = new Panel(new LinearLayout(Direction.VERTICAL));

            // ── Service selector row ──────────────────────────────────────────
            Panel selectorRow = new Panel(new GridLayout(2));
            ((GridLayout) selectorRow.getLayoutManager()).setHorizontalSpacing(2);

            SystemdService service = new SystemdService();
            List<Service> services = service.services;
            System.out.println(services);

            selectorRow.addComponent(new Label("Service:"));
            for (Service s : services) {
                serviceSelect.addItem(s);
                
            }
            serviceSelect.setReadOnly(true);
            selectorRow.addComponent(serviceSelect);

            root.addComponent(new Separator(Direction.HORIZONTAL)
                    .setLayoutData(LinearLayout.createLayoutData(LinearLayout.Alignment.Fill)));
            root.addComponent(selectorRow);
            root.addComponent(new Separator(Direction.HORIZONTAL)
                    .setLayoutData(LinearLayout.createLayoutData(LinearLayout.Alignment.Fill)));

            // ── Detail area (three columns: left group | spacer | right group) ─
            Panel detailArea = new Panel(new GridLayout(3));
            GridLayout detailGrid = (GridLayout) detailArea.getLayoutManager();
            detailGrid.setHorizontalSpacing(4);
            detailGrid.setVerticalSpacing(0);

            // Left column: Identity + Status
            Panel leftCol = new Panel(new LinearLayout(Direction.VERTICAL));
            addSection(leftCol, "Identity");
            addField(leftCol, "ID", valId);
            addField(leftCol, "Description", valDescription);
            addField(leftCol, "Unit file", valPath);

            leftCol.addComponent(new EmptySpace(new TerminalSize(1, 1)));

            addSection(leftCol, "Status");
            addField(leftCol, "Active", valActiveState);
            addField(leftCol, "Sub-state", valSubState);
            addField(leftCol, "Load", valLoadState);
            addField(leftCol, "Enable state", valFileState);
            Panel pidRow = new Panel(new GridLayout(3));
            ((GridLayout) pidRow.getLayoutManager()).setHorizontalSpacing(1);
            Label pidLabel = new Label(String.format("%-13s", "Main PID:"));
            pidRow.addComponent(pidLabel);
            pidRow.addComponent(valMainPid);
            pidRow.addComponent(killButton);
            leftCol.addComponent(pidRow);

            addField(leftCol, "Active since", valActiveSince);
            addField(leftCol, "State changed", valStateChanged);

            leftCol.addComponent(new EmptySpace(new TerminalSize(1, 1)));
            addSection(leftCol, "Resources");
            addField(leftCol, "Memory", valMemory);
            addField(leftCol, "CPU time", valCpu);
            addField(leftCol, "Tasks", valTasks);
            addField(leftCol, "IP ingress", valIngress);
            addField(leftCol, "IP egress", valEgress);

            detailArea.addComponent(leftCol);

            root.addComponent(detailArea
                    .setLayoutData(LinearLayout.createLayoutData(LinearLayout.Alignment.Fill)));

            // ── Button bar ────────────────────────────────────────────────────
            root.addComponent(new EmptySpace(new TerminalSize(1, 1))
                    .setLayoutData(LinearLayout.createLayoutData(LinearLayout.Alignment.Fill)));
            root.addComponent(new Separator(Direction.HORIZONTAL)
                    .setLayoutData(LinearLayout.createLayoutData(LinearLayout.Alignment.Fill)));

            Panel buttonBar = new Panel(new GridLayout(2));
            ((GridLayout) buttonBar.getLayoutManager()).setHorizontalSpacing(2);

            buttonBar.addComponent(new Button("Save",
                    () -> MessageDialog.showMessageDialog(textGUI, "Save",
                            "Not yet implemented.", MessageDialogButton.OK)));
            buttonBar.addComponent(new Button("Close", window::close)
                    .setLayoutData(GridLayout.createHorizontallyEndAlignedLayoutData(1)));

            root.addComponent(buttonBar);

            // ── Wire up selection listener ─────────────────────────────────────
            serviceSelect.addListener((index, previousIndex, changedByUser) -> updateForm(services.get(index)));

            if (!services.isEmpty()) {
                updateForm(services.get(0));
            }

            window.setComponent(root);
            textGUI.addWindowAndWait(window);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (screen != null) {
                try {
                    screen.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // ── Section header (bold-style label spanning the mini-grid) ─────────────
    private static void addSection(Panel parent, String title) {
        parent.addComponent(new Label("── " + title + " ──"));
    }

    // ── Field row: key label + value label side by side ───────────────────────
    private static void addField(Panel parent, String key, Label valueLabel) {
        Panel row = new Panel(new GridLayout(2));
        ((GridLayout) row.getLayoutManager()).setHorizontalSpacing(1);
        Label keyLabel = new Label(String.format("%-13s", key + ":"));
        row.addComponent(keyLabel);
        row.addComponent(valueLabel);
        parent.addComponent(row);
    }

    // ── Push service data into all value labels ───────────────────────────────
    private static void updateForm(Service s) {
        if (s == null) {
            for (Label l : new Label[] { valId, valDescription, valPath,
                    valActiveState, valSubState, valLoadState, valFileState,
                    valMainPid, valActiveSince, valStateChanged,
                    valMemory, valCpu, valTasks, valIngress, valEgress }) {
                l.setText("-");
            }
            return;
        }

        // Identity
        valId.setText(s.getId());
        valDescription.setText(s.getDescription());
        valPath.setText(s.getFragmentPath());

        // Status
        valActiveState.setText(s.getActiveState());
        valSubState.setText(s.getSubState());
        valLoadState.setText(s.getLoadState());
        valFileState.setText(s.getFileState());
        valMainPid.setText(s.getMainPid());
        killButton.setVisible(!s.getMainPid().equals("-"));
        valActiveSince.setText(s.getActiveEnterTimestamp());
        valStateChanged.setText(s.getStateChangeTimestamp());

        // Resources
        valMemory.setText(s.getMemoryCurrent());
        valCpu.setText(s.getCpuUsageNSec());
        valTasks.setText(s.getTasksCount());
        valIngress.setText(s.getIpIngressBytes());
        valEgress.setText(s.getIpEgressBytes());
    }
}
