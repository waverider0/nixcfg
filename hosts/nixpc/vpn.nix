{ pkgs, ... }:

{
	#age = {
	#	identityPaths = [ ../../secrets/id ];
	#	secrets."wg_laptop" = {
	#		file  = ../../secrets/wg_laptop.age;
	#		owner = "root";
	#		group = "root";
	#		mode  = "0600";
	#	};
	#};

	#networking = {
	#	firewall.allowedUDPPorts = [ 51820 ];
	#	wireguard.enable = true;
	#	wireguard.interfaces.wg0 = {
	#		ips            = [ "10.100.0.2/24" ];
	#		listenPort     = 51820;
	#		privateKeyFile = config.age.secrets.wg_laptop.path;
	#		peers = [{
	#			publicKey           = "{server public key}";
	#			allowedIPs          = [ "0.0.0.0/0" "::/0" ]; # forward all traffic via VPN
	#			endpoint            = "{server ip}:51820";
	#			persistentKeepalive = 25;                     # send keepalives every 25 s. important to keep NAT tables alive
	#		}];
	#	};
	#};

	#systemd.services."wireguard-wg0".serviceConfig = {
	#	NoNewPrivileges         = true;
	#	PrivateTmp              = true;
	#	PrivateDevices          = true;
	#	ProtectHome             = "tmpfs";
	#	ProtectSystem           = "strict";
	#	ProtectKernelModules    = true;
	#	ProtectKernelTunables   = true;
	#	ProtectControlGroups    = true;
	#	RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
	#	SystemCallArchitectures = "native";
	#};

	#services.resolved = {
	#	enable  = true;
	#	dns     = [ "10.100.0.1" ];
	#	domains = [ "~." ];
	#};

	#environment.systemPackages = with pkgs; [ wireguard-tools ];
}
