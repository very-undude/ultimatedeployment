#!/usr/bin/perl

require "kickstart.pl";

sub suse15_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("suse15");
 return $result;
}

sub suse15_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub suse15_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"suse15");
  return ($result);
}

sub suse15_GetDefaultCommandLine
{
  local($template)=@_;
  #local($commandline)="append root=/dev/ram0 textmode=1 load_ramdisk=1 autoyast=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] splash=silent showopts ramdisk_size=4096 init=linuxrc install=http://[UDA_IPADDR]/[OS]/[FLAVOR]/";
  local($commandline)="append root=/dev/ram0 textmode=1 load_ramdisk=1 autoyast=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] splash=silent showopts ramdisk_size=4096 install=http://[UDA_IPADDR]/[OS]/[FLAVOR]/";
  return $commandline;
}

sub suse15_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub suse15_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub suse15_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub suse15_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub suse15_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("suse15");
  return $result;
}

sub suse15_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("suse15",$template,$desttemplate,%info);
  return $result;
}

sub suse15_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"suse15");
  return $result;
}

sub suse15_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("suse15",$template,%config);
  return $result;
}

sub suse15_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("suse15",$template,%info);
  return $result;
}

sub suse15_NewOS_2
{
 # local($result)=&kickstart_NewOS_2("suse15");
local($osflavor)=$formdata{OSFLAVOR};
 print "<CENTER>\n";
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=\"suse15\">\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/suse15.js'></script>\n";
 print "<script language='javascript' src='/js/kickstartnewos.js'></script>\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 # print "<TR><TD>Subtype</TD><TD><SELECT NAME=KICKSTART_SUBOS ID=KICKSTART_SUBOS></SELECT></TD></TR>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 #print "LoadValues(\"KICKSTART_SUBOS\",subosarray);\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";

 return result;
}

sub suse15_ImportOS
{
 local($result)=&kickstart_ImportOS("suse15");
  return $result;
}

sub suse15_ImportOS_DoIt
{
  local($actionid)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";
  local(%args)=&ReadActionArgs($actionid);

  local($initrdlocation)="/boot/loader/initrd;/boot/i386/loader/initrd;/boot/x86_64/loader/initrd";
  local($kernellocation)="/boot/loader/linux;/boot/i386/loader/linux;/boot/x86_64/loader/linux";

  local($result)=&kickstart_ImportOS_DoIt("suse15",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
