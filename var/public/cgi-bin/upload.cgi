#!/usr/bin/perl

local($uploadid)=10;
if ($ENV{QUERY_STRING} =~ /uploadid=([0-9]+)/)
{
 $uploadid=$1;
}
local($fulldestdir)="/local/.".$uploadid;
mkdir($fulldestdir);
chmod 0777, $fulldestdir;
open(LENGTHFILE,">$fulldestdir/fsize");
print LENGTHFILE $ENV{CONTENT_LENGTH} ;
close(LENGTHFILE);

print "Content-Type: text/html\n\n";

my($available)=`/usr/bin/df -B1 $fulldestdir| tail -1 | cut -f4 -d " "`;
my($subs)=$available - $ENV{CONTENT_LENGTH};
#print " Available bytes = $available requested $ENV{CONTENT_LENGTH} subs: $subs<BR>\n";
if ($subs < 0)
{
     print("ERROR:$ENV{CONTENT_LENGTH}:Not enough space");
     exit 3;
}
#exit 3;

use CGI ;
if($TempFile::TMPDIRECTORY){ $TempFile::TMPDIRECTORY = $fulldestdir; }
elsif($CGITempFile::TMPDIRECTORY){ $CGITempFile::TMPDIRECTORY = $fulldestdir; }
$ENV{TMPDIR}=$fulldestdir;
my $query=new CGI;
$|=1;

require "general.pl";

local($fullfilename)=$query->param('upload_file');
local($filename)=$query->{'upload_file'};

for my $k ($query->param())
{
   #next unless my $u=$query->upload($k);
   next unless my $u=$query->upload($k);
   if (!$u && $query->cgi_error())
   {
     print("ERROR:$ENV{CONTENT_LENGTH}:Could not upload $tmpfilename");
     exit 3;
   }
   local($tmpfilename)=$query->tmpFileName($u);
   my ($filename)=$query->uploadInfo($u)->{'Content-Disposition'}=~/filename="(.+?)"/i;
   $filename=~s/^.*\\([^\\]*)$/$1/;
   $destfile="/local/$filename";
   close($filename);
   local($result)=rename($tmpfilename,$destfile);
   if (!$result)
   {
     print("ERROR:$ENV{CONTENT_LENGTH}:Could not rename temporary file $tmpfilename to $destfile");
     exit 3;
   }
   local($result)=chmod(0644,$destfile);
   if ($result ne 1)
   {
     print("ERROR:$ENV{CONTENT_LENGTH}:Could not chmod 0644 the file $destfile");
     exit 4;
   }
}

local(@result)=`rm -f $fulldestdir/fsize`;
#if ($? == 0)
#{
#  &PrintError("Could not remove temporary filesize file $fulldestdir/fsize");
#  exit 2;
#}

local($result)=rmdir($fulldestdir);
if (!$result)
{
  print("ERROR:$ENV{CONTENT_LENGTH}:Could not remove temporary directory $fulldestdir");
  exit 1;
}

print("SUCCESS:$ENV{CONTENT_LENGTH}:Upload of $fullfilename succesfull");
