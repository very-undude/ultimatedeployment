# Patches

This directory contains patches for the UDA

Patches can be installed via the web-interface through System->Upgrade

You have to specify a .tgz file that will be unpacked and the install.sh
in the top directory will be run.

You can create a tgz file by running the following command from this directory:
e.g.:

```
tar -C uda30P2 -cvzf uda30P2.tgz .
```

## uda30P1
 * Test patch to test the upgrade functionality

## uda30P2
 * ADD: Support for Windows 11
 * ADD: EFI support for Windows 10,11
 * ADD: EFI support ESX5,6,7
 * ADD: EFI support Centos + Redhat 7,8
 * ADD: Lots of OVA files, including EFI
 * FIX: Changing deploy ova file in template did not work properly

