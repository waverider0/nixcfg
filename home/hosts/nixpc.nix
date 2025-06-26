{ config, lib, pkgs, ... }:

{
    home = {
        username      = "allen";
        homeDirectory = "/home/allen";

        packages = with pkgs; [
            age
            brave
            fzf
            gimp
            keepassxc
            opentofu
            qbittorrent
            signal-desktop
            spotdl
            vlc
            vscodium
            wireshark
        ];

        file = {
            ".ssh/config".source     = ../../secrets/ssh_config;
            ".ssh/github.pub".source = ../../secrets/github.pub;
            ".ssh/xmr.pub".source    = ../../secrets/xmr.pub;
        };
    };

    age = {
        identityPaths = [ ../../secrets/id ];
        secrets = {
            ".kdbx.kdbx.age" = {
                file = ../../secrets/.kdbx.kdbx.age;
                path = "/home/allen/.kdbx.kdbx";
            };
            "github.age" = {
                file = ../../secrets/github.age;
                path = "/home/allen/.ssh/github";
            };
            "xmr.age" = {
                file = ../../secrets/xmr.age;
                path = "/home/allen/.ssh/xmr";
            };
        };
    };

    programs.tmux.extraConfig = lib.mkAfter ''
        set-option -g default-shell "${pkgs.zsh}/bin/zsh"
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
    '';

    qt.kde.settings = {
        kcminputrc = {
            Keyboard.RepeatDelay = 300;
            Keyboard.RepeatRate = 50;
        };
        kglobalshortcutsrc = {
            kwin."Window Maximize"                     = "Meta+Return,Meta+PgUp,Maximize Window";
            kwin."Window Minimize"                     = "Meta+M,Meta+PgUp,Minimize Window";
            services."org.kde.konsole.desktop"._launch = "Meta+Q";
        };
        kwinrc = {
            Desktops   = { Number = 3; Rows = 1; };
            NightColor = { Active = true; Mode = "Constant"; NightTemperature = 3000; };
            Tiling     = { padding = 4; };
            Xwayland   = { Scale = 1; };
        };
    };
}
