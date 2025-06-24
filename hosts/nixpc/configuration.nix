{ config, pkgs, ... }:

{
    imports = [ ./hardware-configuration.nix ];

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    #age = {
    #    identityPaths = [ ../../secrets/id ];
    #    secrets."wg_laptop" = {
    #        file  = ../../secrets/wg_laptop.age;
    #        owner = "root";
    #        group = "root";
    #        mode  = "0600";
    #    };
    #};

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking = {
        hostName                 = "nixos";
        networkmanager.enable    = true;
        firewall.allowedUDPPorts = [ 51820 ];

        #wireguard.enable = true;
        #wireguard.interfaces.wg0 = {
        #    ips            = [ "10.100.0.2/24" ];
        #    listenPort     = 51820;
        #    privateKeyFile = config.age.secrets.wg_laptop.path;
        #    peers = [{
        #        publicKey           = "{server public key}";
        #        allowedIPs          = [ "0.0.0.0/0" "::/0" ]; # forward all traffic via VPN
        #        endpoint            = "{server ip}:51820";
        #        persistentKeepalive = 25;                     # send keepalives every 25 s. important to keep NAT tables alive
        #    }];
        #};
    };

    #systemd.services."wireguard-wg0".serviceConfig = {
    #    NoNewPrivileges         = true;
    #    PrivateTmp              = true;
    #    PrivateDevices          = true;
    #    ProtectHome             = "tmpfs";
    #    ProtectSystem           = "strict";
    #    ProtectKernelModules    = true;
    #    ProtectKernelTunables   = true;
    #    ProtectControlGroups    = true;
    #    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
    #    SystemCallArchitectures = "native";
    #};

    services = {
        displayManager.sddm.enable = true;
        desktopManager.plasma6.enable = true;

        xserver = {
            enable      = true;
            xkb.layout  = "us";
            xkb.variant = "";
        };

        keyd = {
            enable = true;
            keyboards.default.settings.main.capslock = "overload(control, esc)";
        };

        pipewire = {
            enable            = true;
            alsa.enable       = true;
            alsa.support32Bit = true;
            pulse.enable      = true;
        };

        #resolved = {
        #    enable  = true;
        #    dns     = [ "10.100.0.1" ];
        #    domains = [ "~." ];
        #};

        qemuGuest.enable = true;
        spice-vdagentd.enable = true;
    };

    environment.systemPackages = with pkgs; [
        brave
        curl
        fzf
        gimp
        git
        htop
        keepassxc
        lm_sensors
        neovim
        opentofu
        qbittorrent
        qemu
        signal-desktop
        thunderbird
        tmux
        tree
        vlc
        vscodium
        wget
        wireguard-tools
        wl-clipboard
    ];

    programs = {
        gnome-disks.enable = true;
        virt-manager.enable = true;
        zsh.enable = true;
    };

    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    users = {
        defaultUserShell = pkgs.zsh;
        groups.libvirtd.members = [ "allen" ];
        users.allen = {
            isNormalUser = true;
            description = "allen";
            extraGroups = [ "networkmanager" "wheel" ];
        };
    };

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    hardware.bluetooth.enable = true;
    security.rtkit.enable = true;

    system.stateVersion = "25.05";
}
