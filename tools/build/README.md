# Build

This directory contains the tools to make an OVA build from scratch


# Setup the build environment

* ssh uda
  Make sure you can type the command 'ssh uda' and that it logs in to the 
  uda that is hosting the setup of your new build. This should be configured
  for use with public key authentication.

* ssh esx
  Make sure you can type the command 'ssh esx' and that it logs in to the
  esx server that will host new uda build. This should be configured 
  for use with public key authentication

# The files in this directory:

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

