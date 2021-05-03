#!/usr/bin/perl

my($currentos)="debian_8_x64";

if ($currentos eq   'debian_10_x64') {
  $currentarch      ='amd64';
  $currentversion   ='10';
  $currentarchshort ='amd';
  $currentcodename  ='buster';
} elsif ($currentos eq  'debian_10_i386') {
  $currentarch      ='i386';
  $currentversion   ='10';
  $currentarchshort ='386';
  $currentcodename  ='buster';
} elsif ($currentos eq  'debian_9_x64'){
  $currentarch      ='amd64';
  $currentversion   ='9';
  $currentarchshort ='amd';
  $currentcodename  ='stretch';
} elsif ($currentos eq  'debian_9_i386') {
  $currentarch      ='i386';
  $currentversion   ='9';
  $currentarchshort ='386';
  $currentcodename  ='stretch';
} elsif ($currentos eq  'debian_8_x64') {
  $currentarch      ='amd64';
  $currentversion   ='8';
  $currentarchshort ='amd';
  $currentcodename  ='jessie';
} elsif ($currentos eq 'debian_8_i386') {
  $currentarch      ='i386';
  $currentversion   ='8';
  $currentarchshort ='386';
  $currentcodename  ='jessie';
} else {
  print "<H1>Unknown debian os name: $currentos</H1>";
}

require "kickstart.pl";

sub debian8x64_NewTemplate_2
{
 my($result)=&kickstart_NewTemplate_Finish("debian8x64");
 return $result;
}

sub debian8x64_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub debian8x64_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"debian8x64");
  return ($result);
}

sub debian8x64_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ramdisk_size=14984 vga=normal console-setup/modelcode=skip netcfg/get_hostname= interface=auto url=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] auto=true priority=critical debian-installer/allow_unauthenticated=true -- ";
  return $commandline;
}

sub debian8x64_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub debian8x64_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub debian8x64_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub debian8x64_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub debian8x64_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("debian8x64");
  return $result;
}

sub debian8x64_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("debian8x64",$template,$desttemplate,%info);
  return $result;
}

sub debian8x64_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"debian8x64");
  return $result;
}

sub debian8x64_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("debian8x64",$template,%config);
  return $result;
}

sub debian8x64_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("debian8x64",$template,%info);
  return $result;
}

sub debian8x64_NewOS_2
{
 local($kickstartos)="debian8x64";

 local($osflavor)=$formdata{OSFLAVOR};
 print "<CENTER>\n";
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM ENCTYPE=\"multipart/form-data\" METHOD=\"POST\" ACTION=\"/cgi-bin/upload_debian8x64.cgi\">\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=$kickstartos>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/$kickstartos.js'></script>\n";
 print "<script language='javascript' src='/js/kickstartnewos.js'></script>\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<P>You will need to supply the netboot.tar.gz for your distribution version that is able to netboot.</p>\n";
 print "<P>e.g. for Debian $currentversion $currentarch get it <A HREF=\"http://ftp.nl.debian.org/debian/dists/$currentcodename/main/installer-$currentarch/current/images/netboot/netboot.tar.gz\">here</A></p>\n";
 print "<TABLE>\n";
 print "<TR><TD>Neboot initrd image</TD><TD><INPUT TYPE=FILE NAME=NETBOOTIMAGE></TD></TR>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";

 return result;
}

sub debian8x64_ImportOS
{
  local($result)=&kickstart_ImportOS("debian8x64");
  return 0;
}

sub debian8x64_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install.$currentarchshort/initrd.gz";
  local($kernellocation)="/install.$currentarchshort/vmlinuz";
  local($kickstartos)="debian8x64";

  # local($result)=&kickstart_ImportOS_DoIt($kickstartos,$kernellocation,$initrdlocation,$actionid);

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { 
    &UpdateActionProgress($actionid,-1,"Could not read arguments"); 
    return 1;
  }

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local(%osinfo)=();
  $osinfo{FLAVOR}=$args{"OSFLAVOR"};
  $osinfo{OS}=$kickstartos;
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  }
  $osinfo{MOUNTPOINT_1}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{FILE_1}="$TFTPDIR/vmlinuz.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_2}="$TFTPDIR/initrd.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_3}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}.Release.gpg";
  $osinfo{FILE_4}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}.InRelease";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};

  local($initrd)="$osinfo{MOUNTPOINT_1}$initrdlocation";
  local($vmlinuz)="$osinfo{MOUNTPOINT_1}$kernellocation";

  local($result)=&CreateDir("$WWWDIR/$osinfo{OS}");
  if ($result) 
  { 
     &UpdateActionProgress($actionid,-2,"Could not create $WWWDIR/$osinfo{OS}"); 
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created/checked os directory $WWWDIR/$osinfo{OS}");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not write OS information");
    return 1;
  }
  &UpdateActionProgress($actionid,15,"Wrote OS information");

  local($result)=&CreateDir($osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_1}");
    return 3;
  }
  &UpdateActionProgress($actionid,20,"Created flavor mount directory $osinfo{MOUNTPOINT_1}");

  local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");

  my($codename)=`find $osinfo{MOUNTPOINT_1}/dists/*  -maxdepth 0 -type d`;
  $codename =~ s/.*\/([^\/]+)$/\1/g;
  chomp($codename);

  local($result)=&ImportFile($vmlinuz,$osinfo{FILE_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy vmlinuz $vmlinuz to $osinfo{FILE_1}");
    return 5;
  }
  &UpdateActionProgress($actionid,50,"Copied vmlinuz");

  local($result)=&ImportFile($initrd,$osinfo{FILE_2});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy initrd $initrd to $osinfo{FILE_2}");
    return 6;
  }
  &UpdateActionProgress($actionid,60,"Copied initrd");

  local($filenum)=5;
  for $file (@otherfiles)
  {
     local($filestring)=sprintf("FILE_%d",$filenum);
     local($basename)=&basename($file);
     $osinfo{$filestring}="$TFTPDIR/$osinfo{OS}.$osinfo{FLAVOR}.$basename";
     local($result)=&ImportFile($osinfo{MOUNTPOINT_1}."/".$file,$osinfo{$filestring});
     if ($result)
     {
       &UpdateActionProgress($actionid,-2,"Could not copy file $file to $osinfo{$filestring}");
       return 6;
     }
     &UpdateActionProgress($actionid,70+$filenum,"Copied $file");
     $filenum++;
  }

  local($netboot)=$TFTPDIR."/debian8x64/".$args{OSFLAVOR}."/netboot.tar.gz";
  local($netboot2)=$TFTPDIR."/debian8x64/".$args{OSFLAVOR}."/netboot2.tar.gz";
  local($initrd)=$TFTPDIR."/initrd.debian8x64.".$args{OSFLAVOR};
  local($netbootinitrd)=$TFTPDIR."/debian8x64/".$args{OSFLAVOR}."/debian-installer/$currentarch/initrd.gz";

  my($netbootarch)=`tar -tvzf $netboot | grep initrd.gz | cut -f 4 -d /`;
  chomp($netbootarch);
  my($netbootversion)=`tar -xOvzf $netboot ./version.info 2>/dev/null| grep version | awk '{print \$3}'`;
  chomp($netbootversion);
  print "<LI>Version and architecture found in netboot file: |$netbootversion| |$netbootarch|";
  
  if ($netbootarch ne $currentarch or $netbootversion ne $currentversion)
  {
     &UpdateActionProgress($actionid,-2,"Netboot file (Debian $netbootversion $netbootarch) is not intended for this os import ($currentversion $currentarch)");
     return 2;
  }

  local($command)="tar -C $TFTPDIR/debian8x64/".$args{OSFLAVOR}." -xvzf $netboot ./debian-installer/$currentarch/initrd.gz";
  my($result)=&RunCommand($command,"extracting initrd from netboot file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not extract initrd from netboot file");
  }
  &UpdateActionProgress($actionid,77,"Extracted initrd from netboot file");

  my($result)=&CreateDir("$netboot.dir");
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create directory $netboot.dir");
     return 2;
  }
  &UpdateActionProgress($actionid,75,"Created directory $netboot.dir");

  my($result)=&CreateDir("$netboot2.dir");
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create directory $netboot2.dir");
     return 2;
  }
  &UpdateActionProgress($actionid,76,"Created directory $netboot2.dir");

  my($command)="cd $netboot.dir ; cat $netbootinitrd | /usr/bin/gzip -d -c | /usr/bin/cpio -id";
  my($result)=&RunCommand($command,"extracting netboot file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not extract netboot file");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Extracted netboot file");

  my($nbkernelversiondir)=`ls -1 $netboot.dir/lib/modules/`;
  chomp($nbkernelversiondir);
  print "<LI>nb kernel version = $nbkernelversiondir\n";

  my($command)="cd $netboot2.dir ; cat $initrd | /usr/bin/gzip -d -c | /usr/bin/cpio -id ";
  my($result)=&RunCommand($command,"extracting scsi drivers");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not extract scsi drivers file");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Extracted scsi drivers");

  my($isokernelversiondir)=`ls -1 $netboot2.dir/lib/modules/`;
  chomp($isokernelversiondir);
  print "<LI>ISO kernel version = $isokernelversiondir\n";

  my($command)="mkdir -p $netboot.dir/lib/modules/$isokernelversiondir/kernel/ ; cp -r $netboot2.dir/lib/modules/$isokernelversiondir/kernel/* $netboot.dir/lib/modules/$isokernelversiondir/kernel/";
  my($result)=&RunCommand($command,"Copying kernel modules");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Error copying kernel modules");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Copied kernel modules");

  my($modulesdeb)=`find $osinfo{MOUNTPOINT_1} |  grep nic-modules`;
  chomp($modulesdeb);
  &UpdateActionProgress($actionid,77,"Modules.deb=$modulesdeb");

  my($command)="mkdir $TFTPDIR/debian8x64/$args{OSFLAVOR}/niclibs ; cd $TFTPDIR/debian8x64/$args{OSFLAVOR}/niclibs ; ar -vx $modulesdeb";
  my($result)=&RunCommand($command,"unpacking nic modules udeb file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Error unpacking nic modules udeb file");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Unpacked nic modules udeb file");

  my($command)="mkdir $TFTPDIR/debian8x64/$args{OSFLAVOR}/nicmods ; tar -C $TFTPDIR/debian8x64/$args{OSFLAVOR}/nicmods -xf $TFTPDIR/debian8x64/$args{OSFLAVOR}/niclibs/data.tar.xz";
  my($result)=&RunCommand($command,"unpacking nic modules");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Error unpacking nic modules");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Unpacked nic modules");

  my($command)="cp -r $TFTPDIR/debian8x64/$args{OSFLAVOR}/nicmods/lib $netboot.dir ";
  my($result)=&RunCommand($command,"Copying network modules to boot image");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Error copying network modules to boot image");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Copied network modules to boot image");

  my($command)="sudo gpg --armor --export | gpg --import --no-default-keyring --keyring $netboot.dir/usr/share/keyrings/debian-archive-keyring.gpg";
  my($result)=&RunCommand($command,"Adding gpg public key to archive keyring ");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Adding gpg public key to archive keyring");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Added gpg public key to archive keyring");

  my($command)="sudo gpg --armor --export | gpg --import --no-default-keyring --keyring $netboot.dir/usr/share/keyrings/debian-archive-$codename-automatic.gpg";
  my($result)=&RunCommand($command,"Adding gpg public key to archive keyring ");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Adding gpg public key to archive keyring");
    return 2;
  }
  &UpdateActionProgress($actionid,77,"Added gpg public key to archive keyring");

  my($command)="cd $netboot.dir ; find . | cpio --create --format='newc' | gzip > $netboot2";
  my($result)=&RunCommand($command,"Creating netboot2 file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create netboot2 file");
    return 2;
  }
  &UpdateActionProgress($actionid,88,"Created netboot2 file");

  my($command)="rm -rf $netboot.dir";
  my($result)=&RunCommand($command,"removing $netboot.dir directory");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove $netboot.dir directory ");
    return 2;
  }
  &UpdateActionProgress($actionid,88,"Removed $netboor.dir directory");

  my($command)="rm -rf $netboot2.dir";
  my($result)=&RunCommand($command,"removing $netboot2.dir directory");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove $netboot2.dir directory ");
    return 2;
  }
  &UpdateActionProgress($actionid,89,"Removed $netboot2.dir directory");

  my($result)=&ImportFile($netboot2,$initrd);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not Import netboot to initrd file");
    return 2;
  }
  &UpdateActionProgress($actionid,90,"Imported netboot file");

  my($releasefile)="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/dists/$codename/Release";
  my($command)="sudo gpg -abs -o $osinfo{FILE_3} $releasefile ; sudo chown apache:apache $osinfo{FILE_3}";
  my($result)=&RunCommand($command,"Creating GPG signed Release file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Creating GPG signed Release file");
    return 2;
  }
  &UpdateActionProgress($actionid,91,"Created GPG signed Release file");

  my($releasefile)="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/dists/$codename/Release";
  my($command)="sudo gpg --clearsign -o $osinfo{FILE_4} $releasefile ; sudo chown apache:apache $osinfo{FILE_4}";
  my($result)=&RunCommand($command,"Creating GPG signed InRelease file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Creating GPG signed InRelease file");
    return 2;
  }
  &UpdateActionProgress($actionid,92,"Created GPG signed InRelease file");

  $osinfo{DIR_1}=$TFTPDIR."/".$osinfo{OS}."/".$osinfo{FLAVOR};
  my($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not write OS information to file");
    return 7;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return $result;
}

1;
