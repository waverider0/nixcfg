{ config, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    nixpkgs.config.allowUnfree = false;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelParams = [ "ip=dhcp" ];
        initrd = {
            availableKernelModules = [ "r8169" ];
            network.enable = true;
            network.flushBeforeStage2 = true;
            network.ssh = {
                enable = true;
                port = 22;
                authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcaLF+nl/+D8skterj4Rz8MbwBrCrATWpmYwNt3CnMN" ];
                hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
                shell = "/bin/cryptsetup-askpass";
            };
        };
    };

    networking = {
        hostName = "nixos";
        networkmanager.enable = true;
        firewall.allowedTCPPorts = [ 22 ];
    };

    services = {
        resolved.enable = true;

        openssh = {
            enable = true;
            ports = [ 22 ];
            hostKeys = [
                { path = "/etc/secrets/initrd/ssh_host_ed25519_key"; type = "ed25519"; }
            ];
        };

        tor = {
            enable = true;
            client.enable = true;
            hiddenServices.monerod = {
                version = 3;
                path = "/var/lib/tor/monerod";
                map = [
                    { port = 18084; target.addr = "127.0.0.1"; target.port = 18084; }
                    { port = 18089; target.addr = "127.0.0.1"; target.port = 18089; }
                ];
            };
        };

        monero = {
            enable = true;
            dataDir = "/var/lib/monero";
            rpc = {
                restricted = true;
                address = "127.0.0.1";
                port = 18089;
            };
            extraConfig = ''
                prune-blockchain=1
                p2p-bind-ip=0.0.0.0
                p2p-bind-port=18080
                tx-proxy=tor,127.0.0.1:9050,disable_noise
                anonymous-inbound=${
                    builtins.replaceStrings ["\n"] [""]
                        (builtins.readFile "/var/lib/tor/monerod/hostname")
                }:18084,127.0.0.1:18084,24
                disable-rpc-ban=1
            '';
        };
    };

    environment.systemPackages = with pkgs; [
        curl
        neovim
        tmux
        wget
        wl-clipboard
    ];

    users.defaultUserShell = pkgs.zsh;
    users.users.user = {
        isNormalUser = true;
        description = "user";
        extraGroups = [ "networkmanager" "wheel" ];
    };

    system.stateVersion = "25.05";
}
