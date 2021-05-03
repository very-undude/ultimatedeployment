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

$|=1;

local($BASEDIR)="/var/public";
local($FILESDIR)=$BASEDIR."/files";
local($CONFDIR)=$BASEDIR."/conf";
local($TFTPDIR)=$BASEDIR."/tftproot";
local($WWWDIR)=$BASEDIR."/www";
local($TEMPDIR)=$BASEDIR."/tmp";
local($TEMPLATEDIR)=$WWWDIR."/templates";
local($BINDIR)=$BASEDIR."/bin";
local($CGIDIR)=$BASEDIR."/cgi-bin";
local($PXECFG)=$TFTPDIR."/pxelinux.cfg";
local($DEFAULTFILE)=$PXECFG."/default";
local($MESSAGES)=$TFTPDIR."/message.txt";
local($MESSAGESHEADER)=$TFTPDIR."/message.hdr";
local($TEMPLATESCONF)=$CONFDIR."/templates.conf";
local($OSCONF)=$CONFDIR."/os.conf";
local($MOUNTSCONF)=$CONFDIR."/mounts.conf";
local($SMBMOUNTDIR)=$BASEDIR."/smbmount";
local($RESOLVCONF)="/etc/resolv.conf";

local($newdir)="";
local($orgfilesize)=500000000;

sub PrintHeader
{
print "Content-Type: text/html\n\n";
local($header)= <<EOT;
<HTML>
<HEAD>
<TITLE>UDA</TITLE>
<STYLE>
 body { color: black; background: white; font-family: arial,sans-serif; 
  margin-left: 5%; margin-right: 5%;}
  pre { color: black; background: #99CCFF; font-family: monospace; border: solid; 
  border-width: thin; padding: 0.5em;}
  h1 { font-size: 200%; color: #05057A;}
  h2 { font-size: 150%; color: #05057A; margin-left: -1%;}
  h3 { font-size: 125%; color: black;}
  td { font-size: 75%;}
  div.box { border: solid; border-width: thin; width: 100% }
  div.center { text-align:center }
  .right { float:right }
  .left { float:left }
  div.color {
    background: #ADD7E6;
    padding: 0.5em;
    border: none;
    font-family: monospace;
  }
  strong { font-size: 90%; color: red }
  .gb { color: #197D1D; font-size: 110%; }
  .noborder { border-style: none }  
  li.sp { padding-bottom:12px }
  
  a:link {color:blue}
  a:visited {color:purple}
  a:focus {color:teal}
  a:hover {color:teal}
  a:active {color:red}
</STYLE>
</HEAD>
<BODY>
<TABLE CELLPADDING=0 BORDER=0 CELLSPACING=0 WIDTH=100%>
  <TR WIDTH=100%>
   <TD COLSPAN=6 BGCOLOR=#446677 WIDTH=100%>
      <CENTER><H1><FONT COLOR=WHITE>Ultimate Deployment Appliance</FONT></H1></CENTER>
      <CENTER><FONT COLOR=WHITE>Removing SAN Drivers from ESX 3.0.x</FONT></CENTER><BR>
      <CENTER><FONT COLOR=WHITE>Version 1.0</FONT></CENTER><BR>
   </TD>
  </TR>
</TABLE>
EOT
print $header
}

sub GetFormData{

        local(%formdata,$data,$key,$value);
        if ($ENV{'REQUEST_METHOD'}=~/^GET$/i){
                $data=$ENV{'QUERY_STRING'};
        }
        if ($ENV{'REQUEST_METHOD'}=~/^POST$/i){
                $length=$ENV{'CONTENT_LENGTH'};
                read(STDIN,$data,$length);
        }
        if ($ENV{'REQUEST_METHOD'}!~/T/i){
                $data=$ARGV[0];
                $data=~s/@/&/g;
        }
        ### Splits data op &-teken voor de aparte key-value velden
        @parms=split(/&/,$data);
        foreach (@parms){
                ($key,$value)=split(/=/);
                $formdata{&decode($key)}=$formdata{&decode($key)}.&decode($value).',';
        }
        foreach (keys(%formdata)){
                $formdata{$_}=~s/,$//;
        }
        return %formdata;
}

sub decode
{
 local ($instring)=@_;
 $instring=~s/\+/ /g;
 $instring=~s/%([0-9A-F]{2})/pack('c',hex($1))/gei;
 return $instring;
}

sub ChooseIso
{
  print "<H1>Choose a mountpoint and iso file</H1>\n";
  local($filename)=$MOUNTSCONF;
  local(@allisos)=();
  local(@curmounts)=();
  local($result)=open(INFILE,"<$filename");
  while(<INFILE>)
  {
    local($line)=$_;
    chomp($line);
    local($type,$mountdir,$server,$share,$username,$password,$domain)=split(";",$line);
    local($dirname)=$SMBMOUNTDIR."/".$mountdir;
    local($result)=opendir(DIR,"$dirname");
    while($fn=readdir(DIR))
    {
      if(uc($fn) =~ /\.ISO$/)
      {
        push(@allisos,"$mountdir;$fn");
      }
    }
    closedir(DIR);
    push(@curmounts,$mountdir);
  }
  close(INFILE);

  print "<script type=\"text/javascript\">\n function Reload()\n{\n";
  print "var classarray= new Array ()\n";
  for ($i=0;$i<=$#allisos;$i++)
  {
    print "classarray[$i]='$allisos[$i]'\n";
  }

local($form)=<<EOT;
  for (q=document.forms[0].ISOFILE1.options.length;q>=0;q--) 
  {
   document.forms[0].ISOFILE1.options[q]=null ;
  }

  for (i=0; i<classarray.length; i++)
  {
    var pos=classarray[i].indexOf(";")
    var myclass = classarray[i].substr(0,pos)
    var mysubclass=classarray[i].substr(pos+1,classarray[i].length+1)
    if ( myclass == document.forms[0].SHARE.options[document.forms[0].SHARE.selectedIndex].text)
    { 
       myEle = document.createElement("option") ;
       myEle.text = mysubclass ;
       document.forms[0].ISOFILE1.options.add(new Option(mysubclass,mysubclass)) ;
    }
  }
}
</script>
<body>
<FORM NAME=createesx3nosanisoform METHOD=POST ACTION="createesx3nosan.pl">
<INPUT TYPE=HIDDEN NAME=action VALUE=createesx3nosaniso>
EOT

print $form;

print "<INPUT TYPE=HIDDEN NAME=OSID VALUE=$os>\n";

print "<TABLE><TR><TD>Share</TD><TD>";
print "<SELECT NAME=SHARE ONCHANGE=\"Reload()\">\n";
for $themount (@curmounts)
{
   print "<OPTION VALUE=$themount>$themount</OPTION>";
}
print "</SELECT>\n</TD></TR>\n<TR><TD>ISO Filename</TD><TD><SELECT NAME=ISOFILE1></SELECT></TD></TR>\n";

local($form)=<<EOT;
</TABLE>
  <INPUT TYPE=SUBMIT VALUE=OK>
</FORM>
<SCRIPT LANGUAGE=JavaScript>
  Reload()
</SCRIPT>
EOT
print $form;
return 0;
}

sub MountIso
{
  local($fullfilename,$mountdir)=@_;
  ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($fullfilename);
  $orgfilesize=$size;
  print "<LI>Mounting isofile $fullfilename on $mountdir:\n";
  local($command)="/bin/mount -t iso9660 -o loop $fullfilename $mountdir";
  local(@result)=`sudo $command 2>&1`;
  if ($? != 0)
  {
    print "<FONT COLOR=RED>ERROR</FONT>";
    print "<PRE>@result</PRE>\n";
    return 1;
  }
  print "<FONT COLOR=GREEN>OK</FONT>";

  return 0
}

sub RunCommand
{
  local($command,$desc,$mode)=@_;
  if ($mode ne "quiet")
  {
    print "<LI>$desc:";
  }

  # if ($mode eq "debug")
  # {
  #  print "Command = |$command|\n";
  # }

  local(@result)=`sudo sh -c \"$command\" 2>&1`;
  if ($? ne 0)
  {
    if ($mode ne "quiet")
    {
      print "<FONT COLOR=RED>ERROR</FONT>";
      print "<PRE>@result</PRE>\n";
    }
    return 1;
  }
  if ($mode eq "dump")
  {
      print "@result\n";
  }
  if ($mode ne "quiet" && $mode ne "dump")
  {
    print "<FONT COLOR=GREEN>OK</FONT>";
  }
  return 0;
}

sub CreateDir
{
  local($dir)=shift;
  local($mode)=shift;
  if ($mode ne "q") { print "<LI>Creating directory $dir: "; }
  if ( ! -d $dir )
  {
    local($command)="mkdir $dir";
    local(@result)=`sudo $command 2>&1`;
    if ($? ne 0)
    {
      print "<FONT COLOR=RED>ERROR</FONT>\n";
      print "<PRE>@result</PRE>\n";
      return 1;
    }
    if ($mode ne "q") { print "<FONT COLOR=GREEN>OK</FONT>\n"; }
  } else {
    if ($mode ne "q") { print ", Directory $dir exists, good";}
    if ($mode ne "q") { print "<FONT COLOR=GREEN>OK</FONT>\n";}
  }

  if ($mode ne "q") { print "Setting Permissions: \n"; }
  local($command)="chown apache.apache $dir";
  local(@result)=`sudo $command 2>&1`;
  if ($? ne 0)
  {
    print "<FONT COLOR=RED>ERROR</FONT>\n";
    print "<PRE>@result</PRE>\n";
    # return 1;
  }
  if ($mode ne "q") { print "<FONT COLOR=GREEN>OK</FONT>\n";}
  return 0
}

sub ImportFile
{
  local($sfilename,$dfilename)=@_;
  print "<LI>Importing file $sfilename to $dfilename: ";
  if ( -f $sfilename)
  {
     local(@result)=`sudo cp $sfilename $dfilename 2>&1`;
     if ($? != 0)
     {
       print "<FONT COLOR=RED>ERROR</FONT>";
       print "<PRE>@result</PRE>\n";
       return 1;
      }
      print "<FONT COLOR=GREEN>OK</FONT>";
  } else {
    print "File $sfilename not found\n";
    print "<FONT COLOR=RED>ERROR</FONT>";
    return  1
  }
  return 0;
}


sub CreateEsx3NoSanIso
{
  local($share)=$formdata{SHARE};
  local($isofile)=$formdata{ISOFILE1};
  local($fullfilename)=$SMBMOUNTDIR."/$share/$isofile";

  $newdir="$SMBMOUNTDIR/$share/NOSAN.$$.$isofile.TMP";
  # $TEMPDIR=$newdir.".tmp";
  local($mountdir)="$TEMPDIR/esx3withsan";

  local($pxedir)="$mountdir/images/pxeboot";
  local($netstg2)="$mountdir/VMware/base/netstg2.img";
  local($initrd)="$pxedir/initrd.img";


  print "<H2>Generating new isofile without SAN drivers</H2>\n";
  print "Note: Your new file will be called <B>NOSAN.$$.$isofile</B>.\n";
  print "It will be created in the same share ($share) as the orignal file is in.\n";
  print "I will also create a temporary directory there called NOSAN.$$.$isofile.TMP.\n";
  print "This will contain the contents of the entire CD with the SAN drivers removed\n";
  print "This means you will need to have enough room for 3 entire ESX3 CD's\n";
  print "(including the original) in that share.\n";

  print "<H3>Creating Directory Structure</H3>\n";
  local($result)=&CreateDir($TEMPDIR);
  if ($result) { return $result }

  local($result)=&CreateDir($mountdir);
  if ($result) { return $result }

  local($result)=&CreateDir($newdir);
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301");
  if ($result) { return $result }

  local($result)=&CreateDir($newdir."/VMware");
  if ($result) { return $result }

  local($result)=&CreateDir($newdir."/VMware/base");
  if ($result) { return $result }

  local($result)=&CreateDir($newdir."/VMware/RPMS");
  if ($result) { return $result }

  local($result)=&MountIso($fullfilename,$mountdir);
  if ($result) { return $result }

  print "<H3>Importing files</H3>\n";
  local($result)=&ImportFile($mountdir."/VMware/base/comps.xml",$newdir."/VMware/base/comps.xml");
  if ($result) { return $result }

  local($result)=&ImportFile($mountdir."/VMware/base/hdlist",$newdir."/VMware/base/hdlist");
  if ($result) { return $result }

  local($result)=&ImportFile($mountdir."/VMware/base/hdlist2",$newdir."/VMware/base/hdlist2");
  if ($result) { return $result }

  local($result)=&ImportFile($mountdir."/VMware/base/TRANS.TBL",$newdir."/VMware/base/TRANS.TBL");
  if ($result) { return $result }

  local($result)=&ImportFile($mountdir."/VMware/TRANS.TBL",$newdir."/VMware/TRANS.TBL");
  if ($result) { return $result }

  local($result)=&RunCommand("cp  $mountdir/README $newdir/","Copying README","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp  $mountdir/.discinfo $newdir/","Copying .discinfo","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp  $mountdir/TRANS.TBL $newdir/","Copying TRANS.TBL","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp  $mountdir/open_source_licenses.txt $newdir/","Copying open_source_licenses.txt","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp -r $mountdir/dosutils $newdir/","Copying Dosutils","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp -r $mountdir/scripts $newdir/","Copying scripts","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp -r $mountdir/isolinux $newdir/","Copying isolinux","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp -r $mountdir/images $newdir/","Copying images","verbose");
  if ($result) { return $result }

  print "<H3>Modifying initrd</H3>\n";
  local($result)=&ImportFile($initrd,"$TEMPDIR/esx301/initrd.img.gz");
  if ($result) { return $result }

  local($result)=&RunCommand("gzip -d $TEMPDIR/esx301/initrd.img.gz","Unzipping initrd.img","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/initrdmount");
  if ($result) { return $result }

  local($result)=&RunCommand("mount -o loop $TEMPDIR/esx301/initrd.img $TEMPDIR/esx301/initrdmount","Mounting initrd","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/initrdmodules");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/initrdmodules && zcat $TEMPDIR/esx301/initrdmount/modules/modules.cgz | cpio -idvm","Uncompressing initrd modules","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/initrdmodules/2.4.21-37.0.2.ELBOOT/i386/lpf*","Removing Emulex Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/initrdmodules/2.4.21-37.0.2.ELBOOT/i386/qla*","Removing QLogic Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/initrdmodules/ && find -type f | cpio -o -H crc | gzip -n9 > $TEMPDIR/esx301/newinitrdmodules.cgz","Creating new initrd modules.cgz","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("dd if=/dev/zero of=$TEMPDIR/esx301/newinitrd.img bs=1k count=4096","Creating empty initrd ","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("mke2fs -i 1024 -b 1024 -m 5 -F -v $TEMPDIR/esx301/newinitrd.img","Creating filesystem on empty initrd ","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/newinitrdmount");
  if ($result) { return $result }

  local($result)=&RunCommand("mount -t ext2 -o loop $TEMPDIR/esx301/newinitrd.img $TEMPDIR/esx301/newinitrdmount","Mounting new initrd","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("tar -C $TEMPDIR/esx301/initrdmount --exclude=modules/* -cmf  - . | tar -C $TEMPDIR/esx301/newinitrdmount/ -xmf - .","Copying files","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/initrdmount/modules/pcitable | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newinitrdmount/modules/pcitable","Editing pcitable","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/initrdmount/modules/modules.dep | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newinitrdmount/modules/modules.dep","Editing modules.dep","debug");
   if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/initrdmount/modules/modules.pcimap | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newinitrdmount/modules/modules.pcimap","Editing modules.pcimap","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/initrdmount/modules/module-info | sed  -e '/^qla/ { N;N;d }' -e '/^lpf/ {N;N;d}' > $TEMPDIR/esx301/newinitrdmount/modules/module-info","Editing module-info","debug");
  if ($result) { return $result }
 
  local($result)=&RunCommand("umount $TEMPDIR/esx301/initrdmount","Unmounting original initrd","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/initrd.img","Removing original initrd","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cp $TEMPDIR/esx301/newinitrdmodules.cgz $TEMPDIR/esx301/newinitrdmount/modules/modules.cgz","Moving in newly created modules file","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("umount $TEMPDIR/esx301/newinitrdmount","Unmounting new initrd","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("gzip -9 $TEMPDIR/esx301/newinitrd.img","Compressing new initrd","verbose");
  if ($result) { return $result }

  local($result)=&ImportFile("$TEMPDIR/esx301/newinitrd.img.gz",$newdir."/images/pxeboot/initrd.img");
  if ($result) { return $result }
  
  local($result)=&ImportFile("$TEMPDIR/esx301/newinitrd.img.gz",$newdir."/isolinux/initrd.img");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/newinitrd.img.gz","Removing newinitrd.img.gz","verbose");
  if ($result) { return $result } 

  print "<H3>Modifying netstg2</H3>\n";

  local($result)=&ImportFile($netstg2,"$TEMPDIR/esx301/netstg2.img");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/netstg2mount");
  if ($result) { return $result }

  local($result)=&RunCommand("mount -o loop $TEMPDIR/esx301/netstg2.img $TEMPDIR/esx301/netstg2mount","Mounting netstg2","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/netstg2modules");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/netstg2modules && zcat $TEMPDIR/esx301/netstg2mount/modules/modules.cgz | cpio -idvm","Uncompressing netstg2 modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/netstg2modules/2.4.21-37.0.2.ELBOOT/i386/lpf*","Removing Emulex Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/netstg2modules/2.4.21-37.0.2.ELBOOT/i386/qla*","Removing QLogic Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/netstg2modules && find -type f | cpio -o -H crc | gzip -n9 > $TEMPDIR/esx301/newnetstg2modules.cgz","Creating new netstg2 modules.cgz","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/newnetstg2dir");
  if ($result) { return $result }

  local($result)=&RunCommand("tar -C $TEMPDIR/esx301/netstg2mount -cmf - --exclude=modules/* . | tar -C $TEMPDIR/esx301/newnetstg2dir -xmf - .","Copying files","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/netstg2mount/modules/pcitable | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newnetstg2dir/modules/pcitable","Editing pcitable","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/netstg2mount/modules/modules.dep | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newnetstg2dir/modules/modules.dep","Editing modules.dep","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/netstg2mount/modules/modules.pcimap | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newnetstg2dir/modules/modules.pcimap","Editing modules.pcimap","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/netstg2mount/modules/module-info | sed  -e '/^qla/ { N;N;d }' -e '/^lpf/ {N;N;d}' > $TEMPDIR/esx301/newnetstg2dir/modules/module-info","Editing module-info","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("umount $TEMPDIR/esx301/netstg2.img","Unmounting original netstg2","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/netstg2.img","Removing Original netstg2.img","verbose");
  if ($result) { return $result } 

  local($result)=&RunCommand("cp $TEMPDIR/esx301/newnetstg2modules.cgz $TEMPDIR/esx301/newnetstg2dir/modules/modules.cgz","Overwriting modules.cgz","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/newnetstg2modules.cgz","Removing source modules.cgz","verbose");
  if ($result) { return $result }

  print "<LI>Creating new cramfs for netstg.img file\n";
  local($donefile)="$TEMPDIR/esx301/newnetstg2.img.DONE";
  local($errorfile)="$TEMPDIR/esx301/newnetstg2.img.ERROR";
  local($resultfile)="$TEMPDIR/esx301/newnetstg2.img"; 
  local($logfile)="$TEMPDIR/esx301/newnetstg2.img.log";
  local(@result)=`echo "( mkfs.cramfs -v $TEMPDIR/esx301/newnetstg2dir $resultfile 2\>\&1 \>$logfile \&\& touch $donefile ) \|\| touch $errorfile" | at now 2>\&1`;
  # print @result;
  local($curlastlogline)=`tail -1 $logfile`;
  while(1)
  {
    if (-f $donefile || -f $errorfile)
    {
      if (-f $errofile)
      {
        print "<FONT COLOR=RED>Error</FONT><BR>\n";
        local(@result)=`cat $logfile`;
        print "<PRE>@result</PRE>\n";
        print "See $logfile for errors";
        return 1;
      }
    local($newlastlogline)=`tail -1 $logfile`;
    if ($newlastlogline ne $curlastlogline)
    {
      print "<LI>Busy";
      $curlastlogline = $newlastlogline;
    } else {
      print ".";
    }
    last ;
    }
    # Keep the browser busy
    print ".";
    sleep 3;
  }
  print "<FONT COLOR=GREEN>OK</FONT><BR>\n";

  local($result)=&RunCommand("rm -rf $TEMPDIR/esx301/newnetstg2dir","Removing newnetstg2 directory","verbose");
  if ($result) { return $result } 

  local($result)=&ImportFile("$TEMPDIR/esx301/newnetstg2.img" ,$newdir."/VMware/base/netstg2.img");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/newnetstg2.img","Removing newnetstg2.img","verbose");
  if ($result) { return $result } 

  print "<H3>Modifying stage2</H3>\n";
  local($stage2)=$TEMPDIR."/esx301/stage2.img";

  local($result)=&ImportFile($mountdir."/VMware/base/stage2.img",$stage2);
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/stg2mount");
  if ($result) { return $result }

  local($result)=&RunCommand("mount -o loop $stage2 $TEMPDIR/esx301/stg2mount","Mounting stg2","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/stg2modules");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/stg2modules && zcat $TEMPDIR/esx301/stg2mount/modules/modules.cgz | cpio -idvm","Uncompressing stg2 modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/stg2modules/2.4.21-37.0.2.ELBOOT/i386/lpf*","Removing Emulex Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/stg2modules/2.4.21-37.0.2.ELBOOT/i386/qla*","Removing QLogic Driver modules","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cd $TEMPDIR/esx301/stg2modules && find -type f | cpio -o -H crc | gzip -n9 > $TEMPDIR/esx301/newstg2modules.cgz","Creating new stg2 modules.cgz","verbose");
  if ($result) { return $result }

  local($result)=&CreateDir($TEMPDIR."/esx301/newstg2dir");
  if ($result) { return $result }

  local($result)=&RunCommand("tar -C $TEMPDIR/esx301/stg2mount -cmf - --exclude=modules/* . | tar -C $TEMPDIR/esx301/newstg2dir -xmf - .","Copying files","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/stg2mount/modules/pcitable | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newstg2dir/modules/pcitable","Editing pcitable","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/stg2mount/modules/modules.dep | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newstg2dir/modules/modules.dep","Editing modules.dep","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/stg2mount/modules/modules.pcimap | grep -v qla | grep -v lpf > $TEMPDIR/esx301/newstg2dir/modules/modules.pcimap","Editing modules.pcimap","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("cat $TEMPDIR/esx301/stg2mount/modules/module-info | sed  -e '/^qla/ { N;N;d }' -e '/^lpf/ {N;N;d}' > $TEMPDIR/esx301/newstg2dir/modules/module-info","Editing module-info","debug");
  if ($result) { return $result }

  local($result)=&RunCommand("umount $TEMPDIR/esx301/stg2mount","Unmounting original stg2","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $stage2","Removing $stage2","verbose");
  if ($result) { return $result } 

  local($result)=&RunCommand("cp $TEMPDIR/esx301/newstg2modules.cgz $TEMPDIR/esx301/newstg2dir/modules/modules.cgz","Overwriting modules.cgz","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/newstg2modules.cgz","Removing $TEMPDIR/esx301/newstg2modules.cgz","verbose");
  if ($result) { return $result } 

  print "<LI>Creating new cramfs for stage2.img\n";
  local($resultfile)="$TEMPDIR/esx301/newstg2.img";
  local($donefile)=$resultfile.".DONE";
  local($errorfile)=$resultfile.".ERROR";
  local($logfile)=$resultfile.".LOG";
  local(@result)=`echo "( mkfs.cramfs -v $TEMPDIR/esx301/newstg2dir $resultfile 2\>\&1 \>$logfile \&\& touch $donefile ) \|\| touch $errorfile" | at now 2>\&1`;
  local($curlastlogline)=`tail -1 $logfile`;
  while(1)
  {
    if (-f $donefile || -f $errorfile)
    {
      if (-f $errorfile)
      {
        print "<FONT COLOR=RED>ERROR</FONT>\n";
        print "See $logfile for errors\n";
        local(@result)=`cat $logfile`;
        print "<PRE>@result</PRE>\n";
        return 1;
      }
      last ;
    }
    # Keep the broser busy
    local($newlastlogline)=`tail -1 $logfile`;
    if ($newlastlogline ne $curlastlogline)
    {
      print "<LI>Busy";
      $curlastlogline = $newlastlogline;
    } else {
      print ".";
    }
    sleep 3;
  }
  print "<FONT COLOR=GREEN>OK</FONT>\n";

  local($result)=&RunCommand("rm -rf $TEMPDIR/esx301/newstg2dir","Removing $TEMPDIR/esx301/newstg2dir","verbose");
  if ($result) { return $result }

  local($result)=&ImportFile("$TEMPDIR/esx301/newstg2.img" ,$newdir."/VMware/base/stage2.img");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -f $TEMPDIR/esx301/newstg2.img","Removing $TEMPDIR/esx301/newstg2.img","verbose");
  if ($result) { return $result }

  print "<H3>Copying RPM Packages</H3>\n";
  opendir(DIR,"$mountdir/VMware/RPMS");
  while($fn=readdir(DIR))
  {
   if(lc($fn) =~ /\.rpm$/)
   {
     print "<LI>$fn\n";
     local(@result)=`cp $mountdir/VMware/RPMS/$fn $newdir/VMware/RPMS/$fn`;
     if ($? != 0)
     {
      print "<FONT COLOR=RED>Error</FONT> Could not copy rpm file |$fn|\n";
      return 1;
     }
   }
  }
  closedir(DIR);

  return 0;
}

sub CleanUp
{
  local($mountdir)="$TEMPDIR/esx3withsan";

  print "<H3>Cleaning Up</H3>\n";

  local($result)=&RunCommand("umount $mountdir","unmounting $mountdir","verbose");

  local($result)=&RunCommand("rmdir $mountdir","Removing mountpoint $mountdir","verbose");

  local($result)=&RunCommand("rm -rf $TEMPDIR/esx301","Removing Temporary files","verbose");

  return 0;
}

sub MakeIso
{
  print "<H3>Creating ISO file</H3>\n";
  local($isofile)=$formdata{ISOFILE1};
  local($share)=$formdata{SHARE};
  local($resultfile)="$SMBMOUNTDIR/$share/NOSAN.$$.$isofile";
  local($donefile)="$TEMPDIR/$isofile.$$.DONE";
  local($errorfile)="$TEMPDIR/$isofile.$$.ERROR";
  local($logfile)="$TEMPDIR/$isofile.log";
  local(@result)=`echo "( mkisofs -v -l -J -R -r -T -o $resultfile -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $newdir \>$logfile 2>\&1 \&\& touch $donefile ) \|\| touch $errorfile " | at now 2>\&1`;
  # print @result;
  while(1)
  {
    if (-f $donefile || -f $errorfile)
    {
      if (-f $errorfile)
      {
        print "<FONT COLOR=RED>ERROR</FONT><BR>\n";
        print "See $logfile for the error messages\n";
        local(@result)=`cat $logfile`;
        print "<PRE>@result</PRE>\n";
        return 1;
      }
      last ;
    }
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($resultfile);
    if ($size ne "")
    {
      local($progress)=($size / $orgfilesize) * 100;
      local($sizekb)=$size / 1024 ;
      local($orgsizekb)=$orgfilesize / 1024 ;
      printf "<LI>%d\\%d Kb (%d\%)\n", $sizekb,$orgsizekb,$progress;
    }
    sleep 3;
  }
  printf "<LI>%d\\%d Kb (100\%)\n", $orgsizekb, $orgsizekb ;
  print "<FONT COLOR=GREEN>OK</FONT><BR>\n";

  print "<LI>Created $resultfile succesfully!\n";

  local($result)=&RunCommand("chmod -R 777 $newdir/","Setting permissions","verbose");
  if ($result) { return $result }

  local($result)=&RunCommand("rm -rf $errorfile","Removing error file","verbose");

  local($result)=&RunCommand("rm -rf $donefile","Removing done file","verbose");

  local($result)=&RunCommand("rm -rf $logfile","Removing log file","verbose");

  local($result)=&RunCommand("rm -rf $newdir","Removing iso source files","verbose");

  print "<BR><BR><FONT COLOR=GREEN><B>DONE!</B></FONT><BR>";
  return 0;
}

&PrintHeader();

local(%formdata)=&GetFormData();

if ($formdata{action} eq "createesx3nosaniso")
{
  &CreateEsx3NoSanIso();
  &CleanUp();
  &MakeIso();

} else {
  &ChooseIso();
}

