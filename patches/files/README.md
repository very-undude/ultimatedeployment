# UDA PATCH REALEASE NOTES

## uda30P1
 * Test patch to test the upgrade functionality

## uda30P2
 * ADD: Support for Windows 11
 * ADD: EFI support for Windows 10,11
 * ADD: EFI support ESX5,6,7
 * ADD: EFI support Centos + Redhat 7,8
 * ADD: Lots of OVA files, including EFI
 * FIX: Changing deploy ova file in template did not work properly

## uda30P3
  * FIX: EFI subtemplate menu's were not generated properly
  * ADD: extra logging for ipxe menu generation
  * FIX: GENERATEMAC boolean was not enforced for EFI templates
  * ADD: Introducing new patch format where last patch is the only one needed

## uda30P4
  * FIX: Mount after boot did not work properly

## uda30P5
  * FIX: GENERATEMAC during template creation was shown as TEXTBOX instead of CHECKBOX
  * FIX: Generating MAC templates did not work properly

