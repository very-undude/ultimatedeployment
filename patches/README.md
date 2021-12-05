This directory contains patches for the UDA

Patches can be installed via the web-interface through System->Upgrade

You have to specify a .tgz file that will be unpacked and the install.sh
in the top directory will be run.

You can create a tgz file by running the following command from this directory:
e.g.:

```
tar -C files -cvzf latest .
```

This will make sure that each patch includes all previous patches.
