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

sub Progress
{
print "Content-Type: text/html\n";
print "Cache-Control: no-cache\n\n";
local($uploadid)=10;
if ($ENV{QUERY_STRING} =~ /uploadid=([0-9]+)/)
{
  $uploadid=$1;
}
local($temp_dir)="/local/.$uploadid";

## Progress
local($size)=0;
opendir(DIR,"$temp_dir");
while($fn=readdir(DIR))
{
 if($fn =~ /^CGItemp[0-9]+$/)
 {
   ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$temp_dir/$fn");
 }
}
closedir(DIR);

## TotalSize
local($total)=0;
local($result)=open(INFILE,"<$temp_dir/fsize");
while(<INFILE>)
{
  $total=$_;
  chomp($total);
}
close(INFILE);

print "$size/$total";

return 0;

}

&Progress();
