#!/usr/bin/perl

local($fulldestdir)="/var/public/tmp";
use CGI ;
if($TempFile::TMPDIRECTORY){ $TempFile::TMPDIRECTORY = $fulldestdir; }
elsif($CGITempFile::TMPDIRECTORY){ $CGITempFile::TMPDIRECTORY = $fulldestdir; }
my $query=new CGI;
$|=1;

require "general.pl";
&PrintHeader();

local($file1)=$query->param('upload_file1');
local($file2)=$query->param('upload_file2');
local($flavor)=$query->param('flavor');

for my $k ($query->param())
{
   next unless my $u=$query->upload($k);
   local($tmpfilename)=$query->tmpFileName($u);
   my ($filename)=$query->uploadInfo($u)->{'Content-Disposition'}=~/filename="(.+?)"/i;
   $filename=~s/^.*\\([^\\]*)$/$1/;
   local($destdir)="/var/public/tftproot/windows5/$flavor\_inf";
   if (uc($filename) =~ /\.SYS$/)
   {
    $destdir="/var/public/tftproot/windows5/$flavor\_sys"
   }
   $destfile="$destdir/".lc($filename);
   close($filename);
   local($result)=rename($tmpfilename,$destfile);
   if (!$result)
   {
     &PrintError("Could not rename temporary file $tmpfilename to $destfile");
     exit 3;
   }
   local($result)=chmod(0644,$destfile);
   if ($result ne 1)
   {
     &PrintError("Could not chmod 0644 the file $destfile");
     exit 4;
   }
}

require "services.pl";
require "services/binl.pl";
local($result)=&StopService('binl');
if ($result)
{
 # ignoring
}

local($result)=&binl_RebuildInfDb($flavor);
if ($result)
{
  &PrintError("Could not rebuild binl database for $flavor");
}

local($result)=&StartService('binl');
if ($result)
{
  &PrintError("Could not start binl service");
}

&PrintSuccess("Upload of driver files for flavor $flavor succesfull");
