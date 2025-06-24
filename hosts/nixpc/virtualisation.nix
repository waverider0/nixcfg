{ pkgs, ... }:

{
    virtualisation = {
        docker.rootless.enable = true;
        docker.rootless.setSocketVariable = true;
        libvirtd.enable = true;
        spiceUSBRedirection.enable = true;
    };
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [ qemu ];
    users.groups.libvirtd.members = [ "allen" ];
}
