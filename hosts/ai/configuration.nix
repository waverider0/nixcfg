{ config, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    nixpkgs.config.allowUnfree = false;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot = {
        loader.systemd-boot.enable      = true;
        loader.efi.canTouchEfiVariables = true;
        kernelParams                    = [ "ip=dhcp" ];
        initrd = {
            availableKernelModules    = [ "ena" "virtio_net" ];
            network.enable            = true;
            network.flushBeforeStage2 = true;
            network.ssh = {
                enable         = true;
                port           = 22;
                authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcaLF+nl/+D8skterj4Rz8MbwBrCrATWpmYwNt3CnMN" ];
                hostKeys       = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
                shell          = "/bin/cryptsetup-askpass";
            };
        };
    };

    networking = {
        hostName = "ai";
        firewall.allowedTCPPorts = [
            22
            8080
            #11434
        ];
    };

    services = {
        resolved.enable = true;

        #ollama = {
        #    enable = true;
        #    acceleration = "cuda";
        #    listenAddress = "0.0.0.0";
        #};

        openssh = {
            enable   = true;
            ports    = [ 22 ];
            hostKeys = [{ path = "/etc/secrets/initrd/ssh_host_ed25519_key"; type = "ed25519"; }];
        };

        open-webui = {
            enable       = true;
            port         = 8080;
            openFirewall = true;
            environment  = {
                DATA_DIR             = "/var/lib/open-webui";
                OLLAMA_BASE_URL      = "http://127.0.0.1:11434";
                ANONYMIZED_TELEMETRY = "False";
                DO_NOT_TRACK         = "True";
                SCARF_NO_ANALYTICS   = "True";
            };
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
        description  = "user";
        extraGroups  = [ "networkmanager" "wheel" ];
    };

    system.stateVersion = "24.11";
}
