#!/usr/bin/perl

require "kickstart.pl";

sub manual_NewTemplate_2
{

 print "<CENTER>\n";
 print "<H2>New Template Wizard Confirm</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($publish)="ON";
 if (!defined($formdata{PUBLISH})) 
 { 
  $publish = "OFF" ;
 }

 local(%flavorinfo)=&GetOSInfo($formdata{OSFLAVOR});

 print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=manual>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=KERNEL VALUE=\"$flavorinfo{KERNEL}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=INITRD VALUE=\"$flavorinfo{INITRD}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=CMDLINE VALUE=\"$flavorinfo{CMDLINE}\">\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Template Name</TD><TD>$formdata{TEMPLATENAME}</TD></TR>\n";
 print "<TR><TD>Operating System</TD><TD>$kickstartos</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "<TR><TD>Description</TD><TD>$formdata{DESCRIPTION}</TD></TR>\n";
 print "<TR><TD>MAC</TD><TD>$formdata{MAC}</TD></TR>\n";
 print "<TR><TD>Publish</TD><TD>$publish</TD></TR>\n";
 print "<TR><TD>Kernel</TD><TD>$flavorinfo{KERNEL}</TD></TR>\n";
 print "<TR><TD>Initrd</TD><TD>$flavorinfo{INITRD}</TD></TR>\n";
 print "<TR><TD>Command line options</TD><TD>$flavorinfo{CMDLINE}</TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub manual_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub manual_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"manual");
  return ($result);
}

sub manual_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub manual_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub manual_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub manual_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub manual_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub manual_CreateTemplate
{
  local($template)=$formdata{TEMPLATE};

  local($result)=&CheckTemplateName($template);
  if ($result)
  {
    return 1;
  }
  local($flavor)=$formdata{OSFLAVOR};
  local($os)=$formdata{OS};
  local($mac)=$formdata{MAC};
  local($description)=$formdata{DESCRIPTION};
  local($cmdline)=$formdata{CMDLINE};
  local($kernel)=$formdata{KERNEL};
  local($initrd)=$formdata{INITRD};
  local($publish)="ON";
  if (!defined($formdata{PUBLISH}))
  {
    $publish="OFF";
  }

  local(%config)=();
  $config{TEMPLATE}=$template;
  $config{OS}=$os;
  $config{FLAVOR}=$flavor;
  $config{DESCRIPTION}=$description;
  $config{PUBLISH}=$publish;
  $config{MAC}=$mac;
  $config{PUBLISHDIR1}=$TFTPDIR."/manual/".$flavor."/".$template;
  $config{CMDLINE}=$cmdline;
  $config{KERNEL}=$kernel;
  $config{INITRD}=$initrd;

  # Write Config File
  local($result)=&WriteTemplateInfo(%config);
  if ($result) 
  {
    &PrintError("Could not write template info for $template");
    return 1;
  } 

  # Create the kickstart publish directry for this template
  local($result)=&CreateDir($config{PUBLISHDIR1});
  if ($result) 
  {
    &PrintError("Could not create directory $config{PUBLISHDIR1}");
    return 1;
  } 

  if ($config{PUBLISH} eq "ON")
  {
    # print "<LI>PUBLISHING template $template\n";
    local($result)=&PublishTemplate($template);
    if ($result) 
    {
      &PrintError("Could not publish template $template");
      return 1;
    } 
  }

  local($result)=&AddToTemplateSortFile($template);
  if ($result) 
  {
    &PrintError("Could not add template $template to the sort file");
    return 1;
  } 
  

  local($result)=&{"manual_WriteTemplatePXEMenu"}($template,%config);
  if ($result) 
  {
   &PrintError("Could not write PXE menu for template $template");
   return 1;
  } 

  # Writing PXE configuration file
  local($result)=&WriteDefaultFile();
  if ($result) 
  {
   &PrintError("Could not write PXE default file");
   return 1;
  }    
   &PrintSuccess("Created template $template");

  return 0;
}

sub manual_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("manual",$template,$desttemplate,%info);
  return $result;
}

sub manual_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"manual");
  return $result;
}

sub manual_ConfigureTemplate
{
  local($template,%config)=@_;
  # local($result)=&kickstart_ConfigureTemplate("manual",$template,%config);
  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=20 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<BR>\n";
  print "Initrd<BR>\n";
  print "<INPUT TYPE=TEXT NAME=INITRD SIZE=60 VALUE=\"$config{INITRD}\"><BR>\n";
  print "<BR>\n";
  print "Kernel command-line<BR>\n";
  print "<INPUT TYPE=TEXT NAME=CMDLINE SIZE=60 VALUE=\"$config{CMDLINE}\"><BR>\n";
  print "<BR>\n";
  return 0;
}

sub manual_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("manual",$template,%info);
  return $result;
}

sub manual_NewOS_2
{
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM ENCTYPE=\"multipart/form-data\" METHOD=\"POST\" ACTION=\"/cgi-bin/upload_manual.cgi\">\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=manual>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Kernel</TD><TD><INPUT TYPE=FILE NAME=KERNEL></TD></TR>\n";
 print "<TR><TD>Initrd</TD><TD><INPUT TYPE=FILE NAME=INITRD></TD></TR>\n";
 print "<TR><TD>Default Command Line</TD><TD><INPUT TYPE=TEXT NAME=CMDLINE SIZE=60 VALUE=\"initrd=[INITRD]\"></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
 return result;
}

sub manual_ImportOS
{
 local($result)=&kickstart_ImportOS("manual");
  return $result;
}

sub manual_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("manual",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
