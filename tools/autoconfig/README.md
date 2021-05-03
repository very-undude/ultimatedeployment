# UDA Autosetup

UDA autosetup goes through the standard setup wizard applying the answers
you specify in a file autosetup.txt that is in the root of an iso file.
A template for that file is in this directory.

Here's how you would create an iso file containing the files in this directory:

```
cp udasetup.txt /tmp/udasetup

mkisofs  -o /tmp/udasetup.iso -V udasetup -r . 

```

Then attach the iso file as a cdrom to the UDA before you first boot the ova file.

