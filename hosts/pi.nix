{ config, pkgs, ... }:
{
  networking.hostName = "pi";
  time.timeZone = "America/Los_Angeles";

  networking.interfaces.enp1s0.ipv4.addresses = [
    { address = "192.168.12.12"; prefixLength = 24; }
  ];
  networking.interfaces.enp2s0.ipv4.addresses = [
    { address = "10.10.0.1"; prefixLength = 24; }
  ];

  # NAT + forwarding
  networking.nat = {
    enable = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "enp2s0" ];
  };
  networking.firewall.allowedTCPPorts = [ 22 53 67 80 123 ];
  networking.firewall.allowedUDPPorts = [ 53 67 69 123 ];

  # DHCP on lab subnet
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "enp2s0" ];
    extraConfig = ''
      subnet 10.10.0.0 netmask 255.255.255.0 {
        range 10.10.0.50 10.10.0.200;
        option routers 10.10.0.1;
        option domain-name-servers 10.10.0.1;
        filename "netboot.ipxe";
      }
    '';
  };

  # DNS (blocky) – binary via pkgs.goModules
  services.blocky = {
    enable = true;
    settingsFile = pkgs.writeText "blocky.yaml" (builtins.readFile ../blocky.yaml);
    listenAddress = "10.10.0.1";
  };

  # HTTP server
  services.nginx = {
    enable = true;
    virtualHosts."_" = { root = "/srv/http"; };
  };

  # TFTP for PXE if required
  services.atftpd = {
    enable = true;
    root = "/srv/tftp";
    listenAddress = "10.10.0.1:69";
  };

  services.chrony = {
    enable = true;
    allow = [ "10.10.0.0/24" ];
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQkNuY7Ci1Nv4qG2haApZpGN/3uC4moeiQH3/GoN+6++RIHME28Y+LoufDLp6kkE8ZHJWt1ZbKo1e5KMjcDqiGU9BIopC3IYjgQUBxy+YYd//59lCd2xly3vmxs0d6TvV/6Agp/9ZO8cg6vEfrCOUclmM9eMPIvZ6aL7M6JRkC8A5cWOiWOvyOJ/O5N3wPhuOoITZ3pbOI6Ao6GlYosO7EwGl1KG5C8XhZos4aVvrF9XSpPmXj3SH1pi5JM4/AbqGBrrFLXw9LLEGwlrZHwFd9e456LuHVFQ0fjapqxudLLtEiZ8QZgjkolTV3ZMiVXsHd+lY9Me5aTm9VM//XV4YGf1chFYBRDn4D/kZnEhwLhiChGWkUUR0rEwQ3O5MgXR3FL2MgL49EV/2v621c3m6uQciQYu81e5MDl671OAQIMUTzB4in1Oh9quwcXCmp3A5HXwS4m0Iu/OKLvOhIJJUSZExPrq8yfZglQVIRsofqzt2QB33u8Poq/MEjZSc5KApdU4mEdQGWoZEspsqnHB7MMYrp+Jy02J9CRHGmBHXRNOhf+UUJyY906Khc4xBdlnp7vVZj18kNf9evenGMREx0Jxu/982Iwpc5KDye+hR0yeefcao+1mC3hP2A/Qs1Fb0E0PKbRG4nXOpSKjoi3fpQsi1h7UqyVlvavLqVYLV7xQ== zero"
  ];

  system.stateVersion = "24.05";
}}
