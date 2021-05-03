#!/usr/bin/perl

require "kickstart.pl";

sub suse10_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("suse10");
 return $result;
}

sub suse10_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub suse10_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"suse10");
  return ($result);
}

sub suse10_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="append root=/dev/ram0 textmode=1 load_ramdisk=1 autoyast=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] splash=silent showopts ramdisk_size=4096 init=linuxrc install=http://[UDA_IPADDR]/[OS]/[FLAVOR]/";
  return $commandline;
}

sub suse10_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub suse10_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub suse10_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub suse10_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub suse10_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("suse10");
  return $result;
}

sub suse10_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("suse10",$template,$desttemplate,%info);
  return $result;
}

sub suse10_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"suse10");
  return $result;
}

sub suse10_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("suse10",$template,%config);
  return $result;
}

sub suse10_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("suse10",$template,%info);
  return $result;
}

sub suse10_NewOS_2
{
 # local($result)=&kickstart_NewOS_2("suse10");
local($osflavor)=$formdata{OSFLAVOR};
 print "<CENTER>\n";
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=\"suse10\">\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/suse10.js'></script>\n";
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
 #print "<TR><TD>Subtype</TD><TD><SELECT NAME=KICKSTART_SUBOS ID=KICKSTART_SUBOS></SELECT></TD></TR>\n";
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

sub suse10_ImportOS
{
 local($result)=&kickstart_ImportOS("suse10");
  return $result;
}

sub suse10_ImportOS_DoIt
{
  local($actionid)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";
  local(%args)=&ReadActionArgs($actionid);

  local($initrdlocation)="/boot/loader/initrd;/boot/i386/loader/initrd;/boot/x86_64/loader/initrd";
  local($kernellocation)="/boot/loader/linux;/boot/i386/loader/linux;/boot/x86_64/loader/linux";

  local($result)=&kickstart_ImportOS_DoIt("suse10",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
