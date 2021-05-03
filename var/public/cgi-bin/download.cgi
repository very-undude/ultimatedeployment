#!/usr/bin/perl

# Copyright 2006, 2007 Carl Thijssen

# This file is part of the Ultimate Deployment Appliance.
#
# Ultimate Deployment Appliance is free software; you can redistribute
# it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Ultimate Deployment Appliance is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

unshift(@INC,"/var/public/cgi-bin");
require "general.pl" ;
local(%formdata)=&GetFormData();

sub Download
{

  local($type)=$formdata{type};
  if ($type eq "subtemplate")
  {
    local($template)=$formdata{template};
    local($subtemplatefile)="$TEMPLATECONFDIR/$template.sub";
    local($result)=open(STFILE,$subtemplatefile);
    local(@thefile)=<STFILE>;
    close(STFILE);
    print "Content-Type:application/x-download\n";  
    print "Content-Disposition:attachment;filename=$template.txt\n\n";
    print @thefile;
  }
}

&Download();
