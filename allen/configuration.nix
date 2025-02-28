{ config, pkgs, pkgs-2411, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ]; 
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = (with pkgs; [
    direnv
    fzf
    git
    gnupg
    htop
    lsof
    neovim
    pinentry
    tmux
    tree
    wget
    wl-clipboard
    zsh
  ]) ++ (with pkgs-2411; [
    # ...
  ]);

  users.users.allen = {
    isNormalUser = true;
    description = "allen";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    packages = (with pkgs; [
      android-studio
      clang
      discord
      dnsutils
      docker
      ffmpeg
      gimp
      kdePackages.kdenlive
      keepassxc
      nasm
      netcat
      nmap
      obs-studio
      odin
      ollama
      python3
      qbittorrent
      qemu
      ripgrep
      signal-desktop
      spotdl
      tealdeer
      tshark
      ungoogled-chromium
      valgrind
      vlc
      vscodium-fhs
      wireshark
      xournalpp
      yt-dlp
      zig
    ]) ++ (with pkgs-2411; [
        lldb
    ]);
  };

  programs = {
    firefox.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };
  };

  users.defaultUserShell = pkgs.zsh;

  virtualisation.docker.enable = true;

  services = {
    printing.enable = true; # enable CUPS to print documents.
    xserver = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      enable = true;
      layout = "us";
      xkbVariant = "";
    };
  };

  networking = {
    firewall = {
      enable = true;
      # allow inbound TCP connections from a set of manually specified IPs on expo and supabase ports
      extraCommands = ''
        # allowed IPs
        PHONE=192.168.1.161
        DOCKER=172.18.0.0/16

        # expo
        iptables --check nixos-fw --protocol tcp --dport 8081 --source $PHONE --jump ACCEPT || \
        iptables --insert nixos-fw --protocol tcp --dport 8081 --source $PHONE --jump ACCEPT;

        # supabase
        for port in 54321 54322 54323 54324 54327; do
          iptables --check nixos-fw --proto tcp --dport $port --source $DOCKER --jump ACCEPT || \
          iptables --insert nixos-fw --proto tcp --dport $port --source $DOCKER --jump ACCEPT;
        done
      '';
      extraStopCommands = ''
        # allowed IPs
        PHONE=192.168.1.161
        DOCKER=172.18.0.0/16

        # expo
        iptables --check nixos-fw --protocol tcp --dport 8081 --source $PHONE --jump ACCEPT && \
        iptables --delete nixos-fw --protocol tcp --dport 8081 --source $PHONE --jump ACCEPT;

        # supabase
        for port in 54321 54322 54323 54324 54327; do
          iptables --check nixos-fw --protocol tcp --dport $port --source $DOCKER --jump ACCEPT && \
          iptables --delete nixos-fw --protocol tcp --dport $port --source $DOCKER --jump ACCEPT;
        done
      '';
    };
    hostName = "nixos";
    networkmanager.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
