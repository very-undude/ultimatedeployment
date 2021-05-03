#!/usr/bin/perl 

# Copyright 2006, 2007 Carl Thijssen
#
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

sub Browse
{
print "Content-Type: text/html\n";
print "Cache-Control: no-cache\n\n";
local($dir)="/var/public/smbmount/$formdata{mymount}/$formdata{mypath}";
local($result)=opendir(DIR,$dir);
while ($fn=readdir(DIR) )
{
  local($type)="file";
  if ( ! -d "$dir/$fn")
  {
     if ( $fn =~ /\.[Ii][sS][Oo]$/)
     {
       $type="iso";
       print "$fn\n";
     }
  }
}
closedir(DIR);
}

&Browse();
