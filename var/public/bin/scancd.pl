#!/usr/bin/perl
unshift(@INC,"/var/public/cgi-bin");
require "config.pl";
require "general.pl";
require "mounts.pl";
&RemoveAllCDMounts();
&CreateCDMounts();

