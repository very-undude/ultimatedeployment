#!/usr/bin/perl

local($fulldestdir)="/var/public/tmp";
use CGI ;
if($TempFile::TMPDIRECTORY){ $TempFile::TMPDIRECTORY = $fulldestdir; }
elsif($CGITempFile::TMPDIRECTORY){ $CGITempFile::TMPDIRECTORY = $fulldestdir; }
my $query=new CGI;
$|=1;

require "general.pl";
&PrintHeader();

local($name)=$query->param('NAME');
local($description)=$query->param('DESCRIPTION');
local($file1)=$query->param('FILE1');
local($file2)=$query->param('FILE2');
local($drvload)=$query->param('DRVLOAD');

local($destdir)="/var/public/conf/winpedrv/".lc($name);
if (! -d $destdir)
{
  mkdir($destdir);
  if(!result)
  {
     &PrintError("Could not create directory $destdir");
     exit 3;
  }
}
local($lcinf)=lc($file1);
local($lcsys)=lc($file2);
if ($lcinf =~ /([^\\]+)$/) { $lcinf = $1 ; };
if ($lcsys =~ /([^\\]+)$/) { $lcsys = $1 ; };
open(DAT,">$destdir/driver.dat") || &PrintError("Could not open driver datfile $destdir/driver.dat");;
print DAT "NAME=$name\n";
print DAT "DESCRIPTION=$description\n";
print DAT "FILE1=$lcinf\n";
print DAT "FILE2=$lcsys\n";
print DAT "DRVLOAD=$name\.cmd\n";
close(DAT);

local($outfile)=$destdir."/$name.cmd";
local($result)=open(DRVLOADFILE,">$outfile");
print DRVLOADFILE $drvload;
close(DRVLOADFILE);
`/usr/bin/unix2dos $outfile`;

for my $k ($query->param())
{
   next unless my $u=$query->upload($k);
   local($tmpfilename)=$query->tmpFileName($u);
   my ($filename)=$query->uploadInfo($u)->{'Content-Disposition'}=~/filename="(.+?)"/i;
   $filename=~s/^.*\\([^\\]*)$/$1/;
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

&PrintSuccess("Upload of driver files for Windows PE succesfull");
