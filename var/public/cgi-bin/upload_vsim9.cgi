#!/usr/bin/perl

local($fulldestdir)="/var/public/tmp";
use CGI ;
if($TempFile::TMPDIRECTORY){ $TempFile::TMPDIRECTORY = $fulldestdir; }
elsif($CGITempFile::TMPDIRECTORY){ $CGITempFile::TMPDIRECTORY = $fulldestdir; }
my $query=new CGI;
$|=1;

require "general.pl";
&PrintHeader();

local(%osinfo)=();

$osinfo{CMDLINE}=$query->param('CMDLINE');
$osinfo{OS}=$query->param('OS');
$osinfo{FLAVOR}=$query->param('OSFLAVOR');
$osinfo{KERNEL}="memdisk";
$osinfo{FLOPPYIMAGE}="vsim9/$osinfo{FLAVOR}/".$query->param('FLOPPYIMAGE');

local($osdir)="/var/public/tftproot/vsim9";
local($result)=&CreateDir($osdir);
if ($result)
{
  &PrintError("Could not create os directory");
  exit 1;
}

local($flavordir)="/var/public/tftproot/vsim9/$osinfo{FLAVOR}";
local($result)=&CreateDir($flavordir);
if ($result)
{
  &PrintError("Could not create flavor directory");
  exit 1;
}

local($filecount)=1;
for my $k ($query->param())
{
   next unless my $u=$query->upload($k);
   local($tmpfilename)=$query->tmpFileName($u);
   my ($filename)=$query->uploadInfo($u)->{'Content-Disposition'}=~/filename="(.+?)"/i;
   $filename=~s/^.*\\([^\\]*)$/$1/;
   $destfile="$flavordir/floppy.iso";
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
   $osinfo{"FILE_".$filecount}=$destfile;
   $filecount++;
}


require "config.pl";
local($result)=&WriteOSInfo(%osinfo);
if ($result)
{
  &PrintError("Could not write os configuration file");
  exit 4;
}

&PrintSuccess("Import of vsim9 operating system $osinfo{FLAVOR} succesfull");
