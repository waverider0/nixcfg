{ config, lib, pkgs, ... }:

{
    home.homeDirectory = "/Users/allen";
    home.username      = "allen";
    home.packages      = [ pkgs.age ];

    age = {
        identityPaths = [ ../../secrets/id ];
        secrets = {
            "github.age" = {
                file = ../../secrets/github.age;
                path = "/Users/allen/.ssh/github";
            };
            "xmr.age" = {
                file = ../../secrets/xmr.age;
                path = "/Users/allen/.ssh/xmr";
            };
            ".kdbx.kdbx.age" = {
                file = ../../secrets/.kdbx.kdbx.age;
                path = "/Users/allen/.kdbx.kdbx";
            };
        };
    };

    home.file = {
        ".ssh/github.pub".source = ../../secrets/github.pub;
        ".ssh/xmr.pub".source = ../../secrets/xmr.pub;
        "Library/Application Support/VSCodium/User/keybindings.json".text = builtins.toJSON config.programs.vscode.profiles.default.keybindings;
        "Library/Application Support/VSCodium/User/settings.json".text = builtins.toJSON config.programs.vscode.profiles.default.userSettings;
    };

    programs.tmux.extraConfig = lib.mkAfter ''
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'
    '';

    programs.zsh.initContent = lib.mkAfter ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
    '';
}
