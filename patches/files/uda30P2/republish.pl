#!/usr/bin/perl
unshift ( @INC,"/var/public/cgi-bin");
require "templates.pl" ;
&PublishAllTemplates();
