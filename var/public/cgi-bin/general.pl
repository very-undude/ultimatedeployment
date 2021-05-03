#!/usr/bin/perl

$UDAVERSION="3.0";

$BASEDIR="/var/public";
$FILESDIR=$BASEDIR."/files";
$CONFDIR=$BASEDIR."/conf";
$OVACONFDIR=$CONFDIR."/ova";
$TEMPLATECONFDIR=$CONFDIR."/templates";
$MOUNTCONFDIR=$CONFDIR."/mounts";
$OSCONFDIR=$CONFDIR."/os";
$VERSIONDIR=$CONFDIR."/version";
$TFTPDIR=$BASEDIR."/tftproot";
$LOGDIR=$BASEDIR."/log";
$WWWDIR=$BASEDIR."/www";
$TEMPDIR=$BASEDIR."/tmp";
$TMPDIR=$TEMPDIR;
$TEMPLATEDIR=$WWWDIR."/templates";
$BINDIR=$BASEDIR."/bin";
$CGIDIR=$BASEDIR."/cgi-bin";
$OSDIR=$CGIDIR."/os";
$PXECFG=$TFTPDIR."/pxelinux.cfg";
$PXETEMPLATEDIR=$PXECFG."/templates";
$DEFAULTFILE=$PXECFG."/default";
$MESSAGES=$TFTPDIR."/message.txt";
$MESSAGESHEADER=$TFTPDIR."/message.hdr";
$TEMPLATESCONF=$CONFDIR."/templates.conf";
$TEMPLATESORT=$CONFDIR."/templates.sort";
$NFSHEADER=$CONFDIR."/nfsexportheader.conf";
$NFSEXPORTS=$FILESDIR."/exports.conf";
$OVOTEMPLATE=$FILESDIR."/ovofile.txt";
$SHOWTEMPLATELISTFILE="$CONFDIR/showtemplatelist.conf";
$OSCONF=$CONFDIR."/os.conf";
$PXECONF=$CONFDIR."/pxe.conf";
$PXEHEADER=$CONFDIR."/pxedefaultheader.conf";
$PXEMENUITEM=$CONFDIR."/pxedefaultmenuitem.conf";
$PXESUBMENUHEADER=$CONFDIR."/pxedefaultsubmenuheader.conf";
$PXESUBMENUITEM=$CONFDIR."/pxedefaultsubmenuitem.conf";
$OSFLAVORCONF=$CONFDIR."/osflavor.conf";
$MOUNTSCONF=$CONFDIR."/mounts.conf";
$SMBMOUNTDIR=$BASEDIR."/smbmount";
$RESOLVCONF="/etc/resolv.conf";
$WINPECONFDIR=$CONFDIR."/winpedrv";
$MAXISOFILES=6;
%SERVICES=( "dhcpd", "Dynamic Host Control Protocol",
                     "sshd", "Secure Shell Daemon",
                     "smb", "Samba windows sharing",
                     "nfs", "NFS sharing",
                     "httpd", "Web HTTP service",
                     "binl", "Windows Hardware Driver Negotiation",
                     "named", "Domain Name Service",
                     "tftpd", "Trivial FTP" );
@MOUNTTYPES=("NFS;NFS Share","CIFS;Windows Network Share","LOCAL;UDA Local storage","CDROM;Local CDROM Drive");

$OVFTOOLINSTALLED=0;
if (-f "/usr/bin/ovftool")
{
  $OVFTOOLINSTALLED=1;
}
$PWSHINSTALLED=0;
if (-f "/usr/bin/pwsh")
{
  $PWSHINSTALLED=1;
}
$VMTOOLSINSTALLED=0;
if (-f "/usr/bin/vmtoolsd")
{
  $VMTOOLSINSTALLED=1;
}

# General helper functions

sub PrintMenu
{
  print "<TABLE CLASS=menu>";
  print "<TR>";
  print "<TD CLASS=menu1><A CLASS=menu1 HREF=\"uda3.pl?module=system&action=status\">System</A>\n</TD>";
  print "<TD CLASS=menu1><A CLASS=menu1 HREF=\"uda3.pl?module=services&action=list\">Services</A></TD>\n";
  print "<TD CLASS=menu1><A CLASS=menu1 HREF=\"uda3.pl?module=mounts&action=list\">Storage</A></TD>\n";
  print "<TD CLASS=menu1><A CLASS=menu1 HREF=\"uda3.pl?module=os&action=list\">OS</A></TD>\n";
  print "<TD CLASS=menu1><A CLASS=menu1 HREF=\"uda3.pl?module=templates&action=list\">Templates</A></TD>\n";
  print "</TR>\n";
  print "</TABLE>\n";
}

sub PrintHeader
{
  print "Content-Type: text/html\n\n";
  print "<HTML>\n";
  print "<HEAD>\n";
  print "<TITLE>Ultimate Deployment Appliance</TITLE>\n";
  print "<link rel=\"STYLESHEET\" type=\"text/css\" href=\"/default.css\">\n";
  print "</HEAD>\n";
  print "<BODY>\n";
  print "<CENTER>\n";
  print "<H1>Ultimate Deployment Appliance</H1>\n";
  &PrintMenu();
  print "</CENTER>\n";
}

sub PrintFooter
{
  print "</BODY>\n";
  print "</HTML>\n";
}

sub PrintSuccess
{
  local(@lines)=@_;
  print "<CENTER><BR><BR>\n";
  print "<IMG SRC='/icon/accept.png'> Success</FONT><BR><BR>";
  for $line (@lines)
  {
    print $line."<BR>\n";
  }
  print "</CENTER>\n";
}

sub PrintError
{
  local(@lines)=@_;
  print "<CENTER><BR><BR>\n";
  print "<IMG SRC='/icon/cancel.png'> Error</FONT><BR><BR>";
  for $line (@lines)
  {
    print $line."<BR>\n";
  }
  print "</CENTER>\n";
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

sub PrintToolbar
{
  local(@buttons)=@_;

  print "<CENTER>\n";
  print "<TABLE class=toolbar><TR>\n";
  for $button (@buttons)
  {
    print "<TD><INPUT TYPE=BUTTON ID=$button CLASS=toolbarbutton VALUE='$button' ONCLICK='PushButton(this)'></TD>\n";
  }
  print "</TR></TABLE>\n";
  print "</CENTER>\n";
}

sub GetHTMLConfig
{
  local($filename)=@_;
  local(%html);
  local($result)=open(CONFFILE,"<$filename");
  while(<CONFFILE>)
  {
    local($line)=$_;
    chomp($line);
    local(@lineinfo)=split(";",$line);
    local($htmlline)="<TD>".join("</TD><TD>",@lineinfo)."</TD>";
    local($key)=$lineinfo[1];
    $html{$key}=$htmlline;
  }
  close(CONFFILE);
  return (%html);
}

sub CreateDir
{
  local($dir)=shift;
  if ( ! -d $dir )
  {
    local($result)=&RunCommand("mkdir $dir","Creating Directory $dir");
    if ($result ne 0)
    {
      return 1;
    }
  } 
  local($result)=&RunCommand("chown apache.apache $dir","Setting permissions to $dir\n");
  return $result;
}

sub MountIso
{
  local($fullfilename) = shift;
  local($mountdir)=shift;
  local($fstype)=shift;
  if ($fstype ne "udf")
  {
    $fstype="iso9660";
  } 

  local($result)=&RunCommand("/bin/mount -t $fstype -o loop \\\"$fullfilename\\\" \\\"$mountdir\\\"","Mounting $fullfilename on $mountdir");
  return $result;
}

sub PrintProgressBar
{
  print "<div id=\"ProgressbarHolder\" style=\"background-color:#cccccc;border:1px solid black;height:10px;width:300px;padding:0px;\" align=\"left\">";
  print "<div id=\"progress_div\" style=\"position:relative;top:0px;left:0px;background-color:#05057A;height:10px;width:0px;padding-top:5px;padding:0px;\">";
  print "</div></div>\n";
  return 0;
}

sub PrintStatusDiv
{
  print "<div id=\"status_div\">Idle</div>\n";
}


sub GetConfig
{
  local($filename)=@_;
  local(%config);
  local($result)=open(CONFFILE,"<$filename");
  while(<CONFFILE>)
  {
    local($line)=$_;
    chomp($line);
    local(@lineinfo)=split(";",$line);
    local($htmlline)="<TD>".join("</TD><TD>",@lineinfo)."</TD>";
    local($key)=$lineinfo[1];
    $config{$key}=$line;
  }
  close(CONFFILE);
  return (%config);
}

sub PrintJavascriptArray
{
  local($arrayname,@mylist)=@_;
  print "<SCRIPT LANGUAGE=JAVASCRIPT>\n";
  print "var $arrayname= new Array ()\n";
  for ($i=0;$i<=$#mylist;$i++)
  {
    print "$arrayname\[$i\]='$mylist[$i]'\n";
  }
  print "</SCRIPT>\n";
}

sub RunCommand
{
  local($command,$desc,$mode)=@_;
  local(@result)=`sudo sh -c \"$command\" 2>&1`;
  if ($? ne 0)
  {
    print "<PRE>@result</PRE>\n";
    return 1;
  } 
  return 0;
}

sub ImportFile
{
  local($sfilename,$dfilename)=@_;
  if ( -f $sfilename)
  {
    local($result)=&RunCommand("sudo cp $sfilename $dfilename 2>&1","Copying file $sfilename to $dfilename");
    if ($result != 0)
    {
      return 1;
     }
  } else {
    return  1
  }
  return 0;
}

sub ImportFile
{
  local($sfilename,$dfilename)=@_;
  if ( -f $sfilename)
  {
     local(@result)=`sudo cp $sfilename $dfilename 2>&1`;
     if ($? != 0)
     {
       return 2;
      }
  } else {
    return  1
  }
  return 0;
}


sub GetCurSetting
{
  local($type)=shift;
  $type=uc($type);
  local($returnstring)="";
  local($cfgfile)="/etc/sysconfig/network-scripts/ifcfg-eth0";
  local($result)=open(INFILE,"<$cfgfile");
  while(<INFILE>)
  {
    local($line)=$_;
    if($line =~ /^\s*$type\s*=\s*([^\s]*)\s*/)
    {
      $returnstring=$1;
    }
  }
  close(INFILE);
  return $returnstring;
}

sub CheckTemplateName
{
  local($template)=shift;
  if ($template !~ /^[a-zA-Z][a-zA-Z0-9_-]*$/)
  {
    &PrintError("Template name is not valid, should match /^[a-zA-Z][a-zA-Z0-9_-]*\$/");
    return 1;
  }

  if ( -f $TEMPLATECONFDIR."/$template.dat")
  {
    &PrintError("Template name $template already exists");
    return 1;
  }
  return 0;
}

sub GetMountStatusConfig2
{
  local(@result)=`sudo mount`;
  local(%mountconfig)=();
  for $line (@result)
  {
    if ($line =~ /^(.+)\s+on\s+([^\s]+)\s+type\s+([^\s]+)\s+(.*)/)
    {
      local($mount)=$1;
      local($mountpoint)=$2;
      local($type)=$3;
      local($options)=$4;
      if ($type eq "cifs" || $type eq "ext3" || $type eq "iso9660" || $type eq "nfs" || $type eq "udf" || $type eq "xfs")
      {
        $mountconfig{$mountpoint}="$mount;$mountpoint;$type;$options";
      }
    }
  }
  return %mountconfig;
}

sub  GetMountStatusConfig
{
  local(@result)=`cat /etc/mtab`;
  local(%mountconfig)=();
  for $line (@result)
  {
    local(@lineinfo)=split(/\s+/,$line);
    local($mount)=$lineinfo[0];
    local($mountpoint)=$lineinfo[1];
    local($type)=$lineinfo[2];
    local($options)=$lineinfo[3];
    if ($type eq "cifs" || $type eq "ext3" || $type eq "iso9660" || $type eq "nfs" || $type eq "none" || $type eq "udf" || $type eq "xfs")
    {
      $mountconfig{$mountpoint}="$mount;$mountpoint;$type;$options";
    }
  }
  return %mountconfig;
}

sub Home
{
  print "<CENTER>\n";
  print "<H1>Welcome</H1>\n";
  print "Welcome to the Ultimate Deployment Appliance<BR><BR><BR>";
  print "for more information see:<BR>";
  print "<A HREF='http://www.ultimatedeployment.org'>www.ultimatedeployment.org</A>";
  print "</CENTER>\n";
}


1;
