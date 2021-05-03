log-facility local6;

# ddns-update-style ad-hoc;
ddns-hostname = concat("station-",binary-to-ascii(10,8,"-",leased-address));
option host-name = config-option server.ddns-hostname;

next-server [UDA_IPADDR] ;

if substring ( option vendor-class-identifier, 0, 9) = "PXEClient"
{
  filename "pxelinux.0" ;
  next-server [UDA_IPADDR] ;
}

# Jumpstart Support
option space SUNW;
option SUNW.root-mount-options code 1 = text;
option SUNW.root-server-ip-address code 2 = ip-address;
option SUNW.root-server-hostname code 3 = text;
option SUNW.root-path-name code 4 = text;
option SUNW.swap-server-ip-address code 5 = ip-address;
option SUNW.swap-file-path code 6 = text;
option SUNW.boot-file-path code 7 = text;
option SUNW.posix-timezone-string code 8 = text;
option SUNW.boot-read-size code 9 = unsigned integer 16;
option SUNW.install-server-ip-address code 10 = ip-address;
option SUNW.install-server-hostname code 11 = text;
option SUNW.install-path code 12 = text;
option SUNW.sysid-config-file-server code 13 = text;
option SUNW.JumpStart-server code 14 = text;
option SUNW.terminal-name code 15 = text;

subnet [UDA_DHCPSUBNET] netmask [UDA_DHCPNETMASK] {
  option routers [UDA_IPADDR];
  option domain-name-servers [UDA_IPADDR] ;
  range [UDA_DHCPRANGESTART] [UDA_DHCPRANGEEND] ;
  max-lease-time 300;

  # next line is to include template configurations without cluttering the main config file
  include "/var/public/files/dhcpd.d.conf";

}

