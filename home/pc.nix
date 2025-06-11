{ config, pkgs, ... }:

{
    programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        profiles.default.keybindings = [
            {
                key = "ctrl+tab";
                command = "workbench.action.nextEditor";
            }
            {
                key = "ctrl+shift+tab";
                command = "workbench.action.previousEditor";
            }
            {
                key = "ctrl+t";
                command = "workbench.action.quickOpen";
            }
            {
                key     = "ctrl+c";
                command = "workbench.action.closeQuickOpen";
                when    = "inQuickOpen";
            }
        ];
        profiles.default.userSettings = {
            "editor.autoIndent"                 = "none";
            "editor.detectIndentation"          = false;
            "editor.formatOnType"               = false;
            "editor.formatOnPaste"              = false;
            "editor.minimap.enabled"            = false;
            "editor.tabSize"                    = 4;
            "extensions.autoUpdate"             = false;
            "extensions.ignoreRecommendations"  = true;
            "git.openRepositoryInParentFolders" = "never";
            "telemetry.feedback.enabled"        = false;
            "telemetry.telemetryLevel"          = "off";
            "vim.useSystemClipboard"            = true;
            "workbench.startupEditor"           = "none";
            "workbench.editor.empty.hint"       = "hidden";
        };
    };
}
