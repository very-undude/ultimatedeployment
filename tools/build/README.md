# Build

This directory contains the tools to make an OVA build from scratch

## build.sh
Automated script that does the entire build. This is wor in progress.
Currently it requires another UDA to be present that it can SSH to
with via a public key.

## uda30.ova
OVA file only containing only the virtual hardware to make an UDA build

## ks.cfg
Kickstart configuration file that can be used to create the initial install
The kickstart post-install will download a file uda30.tgz from the install host.
That file is essentially a tgz file of the var directory in the repository.
The build.sh takes care of uploading the uda30.tgz file.

