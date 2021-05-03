rem ********************************
rem General Boot parameters
rem ********************************

echo setenv SYS_SERIAL_NUM 1111111111          >> C:\ENV\ENV
echo setenv bootarg.nvram.sysid 1111111-11-1   >> C:\ENV\ENV
echo setenv bootarg.bootmenu.selection 4a      >> C:\ENV\ENV
echo setenv bootarg.vm.sim.vdevinit "36:14:0,36:14:1,36:14:2,36:14:3" >> C:\ENV\ENV
echo setenv bootarg.sim.vdevinit "36:14:0,36:14:1,36:14:2,36:14:3" >> C:\ENV\ENV

rem ********************************
rem Auto Setup parameters for 7-mode
rem ********************************

echo setenv bootarg.setup.auto true            >> C:\ENV\ENV
echo setenv bootarg.setup.hostname vsim        >> C:\ENV\ENV
echo setenv bootarg.setup.nic_e0a "192.168.145.171;255.255.255.0;auto;full;n" >> C:\ENV\ENV
echo setenv bootarg.setup.default_gateway 192.168.145.1 >> C:\ENV\ENV
echo setenv bootarg.setup.admin_password netapp01 >> C:\ENV\ENV
echo setenv bootarg.setup.tmz GMT >> C:\ENV\ENV
echo setenv bootarg.setup.filer_location MyLocation >> C:\ENV\ENV
echo setenv bootarg.setup.sas_mgmt n >> C:\ENV\ENV
echo setenv bootarg.setup.admin_host 192.168.145.7 >> C:\ENV\ENV
echo setenv bootarg.setup.run_dns n >> C:\ENV\ENV
echo setenv bootarg.setup.dns_info "mydomain.local;192.168.145.4" >> C:\ENV\ENV
echo setenv bootarg.setup.run_nis n >> C:\ENV\ENV
echo setenv bootarg.setup.nis_info "mynisdomain;192.168.145.6" >> C:\ENV\ENV
echo setenv bootarg.setup.interface_groups n >> C:\ENV\ENV
echo setenv bootarg.setup.interface_groups_count 1 >> C:\ENV\ENV
echo setenv bootarg.setup.interface_groups_info test >> C:\ENV\ENV

rem ********************************
rem Auto Setup parameters for C-mode
rem ********************************

echo setenv bootarg.setup.auto true >> C:\ENV\ENV
echo setenv bootarg.setup.auto.file "/cfcard/VSA.XML" >> C:\ENV\ENV

copy a:\VSA.XML c:\VSA.XML

fdapm.com warmboot
