{ config, lib, pkgs, ... }:

{
    home.homeDirectory = "/home/allen";
    home.username      = "allen";
    home.packages      = [ pkgs.age ];

    age = {
        identityPaths = [ ../../secrets/id ];
        secrets = {
            "github.age" = {
                file = ../../secrets/github.age;
                path = "/home/allen/.ssh/github";
            };
            "xmr.age" = {
                file = ../../secrets/xmr.age;
                path = "/home/allen/.ssh/xmr";
            };
            ".kdbx.kdbx.age" = {
                file = ../../secrets/.kdbx.kdbx.age;
                path = "/home/allen/.kdbx.kdbx";
            };
        };
    };

    home.file = {
        ".ssh/config".source = ../../secrets/ssh_config;
        ".ssh/github.pub".source = ../../secrets/github.pub;
        ".ssh/xmr.pub".source = ../../secrets/xmr.pub;
        "./config/VSCodium/User/keybindings.json".text = builtins.toJSON config.programs.vscode.profiles.default.keybindings;
        "./config/VSCodium/User/settings.json".text = builtins.toJSON config.programs.vscode.profiles.default.userSettings;
    };


    programs.tmux.extraConfig = lib.mkAfter ''
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
    '';

    qt.kde.settings = {
        kglobalshortcutsrc = {
            kwin."Window Maximize" = "Meta+F,Meta+PgUp,Maximize Window";
            kwin."Window Minimize" = "Meta+M,Meta+PgUp,Minimize Window";
            services."org.kde.konsole.desktop"._launch = "Meta+Q";
        };
        kwinrc = {
            Desktops = { Number = 3; Rows = 1; };
            NightColor = { Active = true; Mode = "Constant"; NightTemperature = 3000; };
            Tiling = { padding = 4; };
            Xwayland = { Scale = 1; };
        };
    };
}
