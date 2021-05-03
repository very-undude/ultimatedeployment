# Tools

## settings.conf
This is a file that contains information that is needed by the tools. 
It holds for instance the ip, username and password of your UDA so that it
can be used by the test scripts, but also the ip, username and password to
be used for OVA deployment.

It is ignored by git, so it will not show up on github unintentionally.  
There is a template file settings.conf.template with bogus information to 
show what it should look like. It is recommended to create a settings.conf 
file outside of the git repository and make a link in this directory that 
points to it. e.g.

```
mkdir ~/.uda
chmod 600 ~/.uda
cp settings.conf.template ~/.uda/settings.conf
ln -sf ~/.uda/settings.conf ./settings.conf

```

## build
These are the build tools. 

It depends on: 

* Being able to ssh to a host called esx without a password as a user with root privileges. 

* An UDA being present that: (TODO: remove the uda ssh dependency)
  * can be reached with ssh without a password on the hostname uda
  * has a centos7.3 distribution configured
  * has a template that automatically installs on the MAC address in the script
  * hosts a tgz file that is uploaded by the script to the /var/public/www directory

## test
This is the test suite. The test scripts are just running a curl request that mimcs
the input being submitted by the user interface. Be aware that the settings.conf 
file will be applied to the System->Variables in the UDA you are testing as well!

## autoconfig
This directory contains the stuff you need to get the uda to do an automatic setup.
It works by adding a cdrom image with a config file in the root directory to the 
UDA VM before the first boot.

## esx
These are some tools that you can use to quickly work with ova files from the command line.

