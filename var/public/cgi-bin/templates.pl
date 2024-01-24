#!/usr/bin/perl

sub DisplayTemplateList
{
  print "<CENTER>\n";
  print "<H2>Templates</H2>\n";
  &PrintToolbar("New","Delete","Copy");
  if ($OVFTOOLINSTALLED)
  {
    &PrintToolbar("Configure","Sort","Deploy");
  } else {
    &PrintToolbar("Configure","Sort");
  }
  print "<FORM NAME=TEMPLATELISTFORM ACTION=\"uda3.pl\">\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=template VALUE=none>\n";
  print "</FORM>\n";
  
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/templates.js'></script>\n";
  print "<BR>\n";
  print "<TABLE BORDER=1 ID='templatesorttable'>\n";
  print "<TR CLASS=tableheader><TD>Template</TD><TD>OS</TD><TD>Flavor</TD><TD>Publish</TD><TD>MAC</TD><TD>Description</TD></TR>\n";
  local(%templateconfig)=&GetTemplateHTMLConfig();
  local(%templatesortorder)=&GetTemplateSortOrder();
  #for $curtemplateconfig (keys(%templateconfig))
  for $curtemplateconfig (sort(keys(%templatesortorder)))
  {
    if (defined($templateconfig{$templatesortorder{$curtemplateconfig}}))
    {
      print "<TR onclick='SelectRow(this)' ID=$templatesortorder{$curtemplateconfig}>$templateconfig{$templatesortorder{$curtemplateconfig}}</TR>\n";
      delete($templateconfig{$templatesortorder{$curtemplateconfig}});
    }
  }
  # put the templates not in the sortorder at the end of the table in random order
  for $mytemplateconfig (sort(keys(%templateconfig)))
  {
    print "<TR onclick='SelectRow(this)' ID=$mytemplateconfig>$templateconfig{$mytemplateconfig}</TR>\n";
  }
  print "</TABLE>\n";
  print "</TABLE>\n";
  print "</CENTER>\n";
  return 0;
}

sub ApplySortTemplateList
{
  local($sort)=$formdata{SORT};
  if ($sort eq "none")
  {
    print "<LI>OK no sortstring found, doing nothing\n";
    return 0;
  }
  local(@sortarray)=split(";",$sort);
  local($result)=&WriteTemplateSortFile(@sortarray);
  if ($result)
  {
    &PrintError("Could not save the template sort");
    return 1;
  }
  local($result)=&WriteDefaultFile();
  if ($result)
  {
    &PrintError("Could not write sorted PXE menu file");
    return 1;
  }

  &DisplayTemplateList();
  return 0;
}

sub SortTemplateList
{
  print "<CENTER>\n";
  print "<H2>Sort Templates</H2>\n";
  &PrintToolbar("Save","Cancel","Up","Down");
  print "<FORM NAME=TEMPLATELISTSORTFORM ACTION=\"uda3.pl\">\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=sort>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=SORT VALUE=none>\n";
  print "</FORM>\n";
  print "<script language='javascript' src='/js/sorttemplates.js'></script>\n";
  print "<script language='javascript' src='/js/tablesort.js'></script>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<BR>\n";
  print " <TABLE BORDER=1 ID='templatesorttable'>\n";
  print "<TR CLASS=tableheader><TD>Template</TD><TD>OS</TD><TD>Flavor</TD><TD>Publish</TD><TD>MAC</TD><TD>Description</TD></TR>\n";
  local(%templateconfig)=&GetTemplateHTMLConfig();
  local(%templatesortorder)=&GetTemplateSortOrder();
  for $curtemplateconfig (sort(keys(%templatesortorder)))
  {
    if (defined($templateconfig{$templatesortorder{$curtemplateconfig}}))
    {
      print "<TR onclick='SelectRow(this)' ID=$curtemplateconfig>$templateconfig{$templatesortorder{$curtemplateconfig}}</TR>";
      delete($templateconfig{$templatesortorder{$curtemplateconfig}});
    }
  }
  for $mytemplateconfig (sort(keys(%templateconfig)))
  {
    print "<TR onclick='SelectRow(this)' ID=$mytemplateconfig>$templateconfig{$mytemplateconfig}</TR>\n";
  }
  print "</TABLE>\n";

  print "</TABLE>\n";
  print "</CENTER>\n";
}

sub NewTemplate
{
  require "os.pl";
  require "config.pl";
  print "<CENTER>\n";
  print "<H2>New Template Wizard Step 1</H2>\n";
  &PrintToolbar("Next","Cancel");
  &PrintJavascriptArray("osarray",&GetOSList());
  &PrintJavascriptArray("flavorarray",&GetOSFlavorList());
  print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
  print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
  print "<script language='javascript' src='/js/validation.js'></script>\n";
  print "<FORM NAME=WIZARDFORM ACTION=\"uda3.pl\">\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=step VALUE=1>\n";
  print "<TABLE>\n";
  print "<TR><TD>Template Name</TD><TD><INPUT TYPE=TEXT NAME=TEMPLATENAME ID=TEMPLATENAME></TD></TR>\n";
  print "<TR><TD>Description</TD><TD><INPUT TYPE=TEXT NAME=DESCRIPTION></TD></TR>\n";
  print "<TR><TD>Operating System</TD><TD><SELECT NAME=OS ID=OS ONCHANGE='ReloadIndexedValues(\"OSFLAVOR\",flavorarray,this.options[this.selectedIndex].value);'></SELECT></TD></TR>\n";
  print "<TR><TD>Flavor</TD><TD><SELECT NAME=OSFLAVOR ID=OSFLAVOR></SELECT></TD></TR>\n";
  print "<TR><TD>Bind to MAC</TD><TD><INPUT TYPE=TEXT NAME=MAC></TD></TR>\n";
  print "<TR><TD>Generate MAC Based PXE config</TD><TD><INPUT TYPE=CHECKBOX NAME=GENERATEMAC></TD></TR>\n";
  print "<TR><TD>Publish</TD><TD><INPUT TYPE=CHECKBOX NAME=PUBLISH CHECKED></TD></TR>\n";
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";
  print "<script language='javascript'>\n";
  print "LoadReferencedValues(\"OS\",osarray,flavorarray);\n";
  print "var OSBox=document.getElementById(\"OS\");\n";
  print "ReloadIndexedValues(\"OSFLAVOR\",flavorarray,OSBox.options[OSBox.selectedIndex].value);\n";
  print "</script>\n";
  return 0;
}


sub DeployTemplate
{
  local($template)=shift;
  require "action.pl";
  local(%info)=&GetTemplateInfo($template);
  print "<CENTER>\n";
  print "<H2>Deploy template $template</H2>\n";
  print "<FORM NAME=WIZARDFORM>\n";
  local($actionid)=$$;
  print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";
  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Template</TD><TD>$template</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Deploy OVA for template $template","templates.pl","\&DeployTemplate_DoIt($actionid);");
  print "<script language='javascript' src='/js/progress.js'></script>\n";
  print "<script language='javascript'>\n";
  print "Update($actionid);\n";
  print "</script>\n";
  print "</CENTER>\n";
}

sub AddMacToFirstNetworkCard
{
  my($infile)=shift;
  my($outfile)=shift;
  my($mac)=shift;

  use XML::LibXML;

  my $dom = XML::LibXML->load_xml(location => $infile, no_blanks => 1);
  my $xpc = XML::LibXML::XPathContext->new($dom);

  my($lowparentaddress)=0;
  my($lowparentid)="";
  my($lowparentbefore)="";
  my($lowparentitem)="";

  foreach my $el ($xpc->findnodes('.//rasd:ResourceType'))
  {
    my $name = $el->localname;
    my $value = $el->to_literal or next;
    print "<LI>Found $name with value $value\n";
    if ($value eq "10")
    {
      my($item)=$el->parentNode;
      my($parentaddress)=$item->getChildrenByTagName('rasd:AddressOnParent');
      my($pa)=$parentaddress->to_literal;
      my($instance)=$item->getChildrenByTagName('rasd:InstanceID');
      my($id)=$instance->to_literal;
      print "<LI>Found network card with instance id $id on parent address $pa\n";
      if ($lowparentid eq "" || int($pa) < $lowparentaddress )
      {
        $lowparentaddress = int($pa);
        $lowparentid=$id;
        $lowparentbefore=$parentaddress;
        $lowparentitem=$item;
      }
    }
  }
  print "Lowest parent address = $lowparentaddress with id $lowparentid\n";
  my($currentaddress)=$lowparentitem->getChildrenByTagName('rasd:Address');
  if (defined($currentaddress))
  {
    my($addr)=$currentaddress->to_literal;
    print "<LI>Removing current address $addr\n";
    $lowparentitem->removeChild($currentaddress);
  }
  print "<LI>Adding mac address $mac to parent id $lowparentid\n";
  my $address = $dom->createElement('rasd:Address');
  $address->appendText($mac);
  $lowparentitem->insertBefore($address, $lowparentbefore);

#  WARNING: if you enable the following piece of code the VM you deploy will ALWAYS 
#  boot from the network and not just once, not very usefull when you do an autodeploy
#  but if you know what you are doing: be my guest 

#  print "<LI>Making sure it boots from the first network card with id $lowparentid\n";
#  foreach my $vs ($xpc->findnodes('.//rasd:ResourceType/../../..'))
#  {
#    my $bootorder=$dom->createElement('vmw:BootOrderSection');
#    $bootorder->setAttribute("vmw:instanceId","$lowparentid");
#    $bootorder->setAttribute("vmw:type","net");
#    my $bootorderinfo=$dom->createElement('Info');
#    $bootorderinfo->appendText('Virtual hardware device boot order');
#    $bootorder->addChild($bootorderinfo);
#    $vs->addChild($bootorder);
#  }

  my($result)=open(OUTFILE,">$outfile");
  print OUTFILE $dom->toString(1);
  close(OUTFILE);

  return 0;
}

sub DeployTemplate_DoIt
{
  local($actionid)=shift;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }

  local($template)=$args{template};
  local(%info)=&GetTemplateInfo($template);
  local(%subinfo)=&GetAllSubTemplateInfo($template);
  local(@configfile)=&GetConfigFile($info{OVOFILE});

   &UpdateActionProgress($actionid,7,"Retrieving ovftool version info: ".$versioninfo[2]);
   my($versioncmdoutput)=`ovftool -v`;
   if ($? != 0)
   {
       &UpdateActionProgress($actionid,-2,"Could not get ovftool version");
       return 2;
   }
   local(@versioninfo)=split(/\s+/,$versioncmdoutput);
   my($major,$minor,$patch)=split(/\./,$versioninfo[2]);
   &UpdateActionProgress($actionid,8,"Retrieved ovftool version info: ".$versioninfo[2]." major: $major minor: $minor patch: $patch");
   my($configoption)=0;
   if (int($major) > 4 || (int($major) == 4 && int($minor) > 3))
   {
     $configoption=1;
   }
   &UpdateActionProgress($actionid,9,"Using configfile option in command line: $configoption");

  if (keys(%subinfo) == 0)
  {
    my($tempdir)="$TMPDIR/action.$actionid/ova.default";
    local($result)=&CreateDir($tempdir);
    if ($result)
    {
       &UpdateActionProgress($actionid,-2,"Could not create temporary directory $tempdir");
       return 2;
    }
    &UpdateActionProgress($actionid,10,"Created temp directory");

    #print "<LI>Writing ovftool options file for template $template\n";
    $info{SUBTEMPLATE}="default" ;
    $info{ACTIONID}=$actionid ;
    local($result)=open(PFILE,">$tempdir/.ovftool");
    for $line (@configfile)
    {
      local($newline)=&FindAndReplace($line,%info);
      print PFILE $newline;
    }
    close(PFILE);
    &UpdateActionProgress($actionid,20,"Wrote settings file");

    print "<LI> MAC ADDRESS is now $info{MAC}\n";
    if($info{MAC} ne "")
    {

      my($cmdline)="mkdir $tempdir/ova ;  tar -C $tempdir/ova -xf /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE}";
      &UpdateActionProgress($actionid,35,"Extracting ova file");
      local($result)=&RunCommand($cmdline,"Extracting ova file");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error extracting OVA file");
         return 2;
      }
      &UpdateActionProgress($actionid,38,"Extracted ova file");

      my($ovffile)=`ls -1 $tempdir/ova/*.ovf`;
      chomp($ovffile);
      &UpdateActionProgress($actionid,40,"ovf file is $ovffile");

      my($newmac)=$info{MAC};
      $newmac =~ s/-/:/g ;
      $tempovf="$tempdir/$newmac.ovf";
      &UpdateActionProgress($actionid,35,"Adding MAC to ovf file");
      local($result)=&AddMacToFirstNetworkCard($ovffile,$tempovf,$newmac);
      if ($result != 0)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error adding MAC to OVF file");
         return 2;
      }
      &UpdateActionProgress($actionid,38,"Added MAC to ovf file");

      my($cmdline)="sudo mv $ovffile $tempdir/; sudo mv $tempovf $ovffile";
      &UpdateActionProgress($actionid,35,"Replacing ovf file");
      local($result)=&RunCommand($cmdline,"Replacing ovf file");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error Replacing ovf file");
         return 2;
      }
      &UpdateActionProgress($actionid,38,"Replacing ovf file");

      my($manifest)=`ls -1 $tempdir/ova/*.mf`;
      chomp($manifest);
      &UpdateActionProgress($actionid,39,"Manifest is $manifest");

      #my($shasum)=`shasum -a 256 $ovffile | awk '{print \$1}'`;
      #my($shasum)=`shasum $ovffile | awk '{print \$1}'`;
      #my($shasum)=`openssl sha1 $ovffile | awk '{print \$2}'`;

      my($ovfbase)=`basename $ovffile`;
      chomp($ovfbase);
      my($shabits)=`sudo sed -E 's,^SHA([0-9]+).$ovfbase.*\$,\\1,g' $manifest`;
      chomp($shabits);
      print "<LI>shabits=|$shabits|\n";
      my($shasum)=`sudo shasum -a $shabits $ovffile | awk '{print \$1}'`;
      chomp($shasum);
      print "<LI>shasum=|$shasum|\n";

      my($cmdline)="sudo sed -i -E 's,^(.*$ovfbase.*=\s*).*,\\1$shasum,g' $manifest";
      &UpdateActionProgress($actionid,35,"Replacing shasum in manifest file");
      local($result)=&RunCommand($cmdline,"Replacing shasum in manifest file");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error Replacing shasum in manifest file");
         return 2;
      }
      &UpdateActionProgress($actionid,38,"Replacing shasum in manifest file");

      my($basename)=`basename /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE}`;
      chomp($basename);

      my($newovafile)="$tempdir/$basename";
      print "<LI> new ova file = $newovafile";
      my($cmdline)="cd $tempdir/ova ; sudo tar -cf $newovafile *.ovf ; sudo mv *.ovf .. ; sudo tar -rf $newovafile * ; cd -";
      &UpdateActionProgress($actionid,35,"Tarring into ova file $newovafile");
      local($result)=&RunCommand($cmdline,"Tarring into ova file");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error tarring into OVA file");
         return 2;
      }
      &UpdateActionProgress($actionid,38,"Tarred to ova file");
      my($configFile)=($configoption==1) ? "--configFile=$tempdir/.ovftool" : "" ;
      my($cmdline)="cd $tempdir ; /usr/bin/ovftool $configFile $tempdir/$basename $info{OVADESTINATION}";
      $cmdline=&FindAndReplace($cmdline,%info);
      print "<LI>cmdline = $cmdline";

      &UpdateActionProgress($actionid,35,"Running ovftool command");
      local($result)=&RunCommand($cmdline,"Running ovftool command");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error running ovftool command");
         return 2;
      }

 
    } else {
      my($configFile)=($configoption==1) ? "--configFile=$tempdir/.ovftool" : "" ;
      my($cmdline)="cd $tempdir ; /usr/bin/ovftool $configFile /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE} $info{OVADESTINATION}";
      $cmdline=&FindAndReplace($cmdline,%info);
      &UpdateActionProgress($actionid,30,"Built command line");

      &UpdateActionProgress($actionid,35,"Running ovftool command");
      local($result)=&RunCommand($cmdline,"Running ovftool command");
      if ($result)
      {
         #print"<LI>Result = $result" 
         &UpdateActionProgress($actionid,-2,"Error running ovftool command");
         return 2;
      }
    }
  } else {
    local($headerline)=$subinfo{__HEADER__};
    #print "<LI>LENGTH= ".keys(%subinfo);

    my($percentpersub)=94/(keys(%subinfo)-1);
    my($percentpersubstep)=int(94/(keys(%subinfo)-1)/13);
    my($curperc)=6;
    for $sub (keys(%subinfo))
    {
      if ($sub ne "__HEADER__")
      {
        &UpdateActionProgress($actionid,$curperc,"Starting deployment of subtemplate $sub for template $template");
        $curperc+=$percentpersubstep;

        local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

        my($tempdir)="$TMPDIR/action.$actionid/ova.$sub";
        local($result)=&CreateDir($tempdir);
        if ($result)
        {
           &UpdateActionProgress($actionid,-2,"Could not create temporary directory $tempdir for subtemplate $sub");
           return 2;
        }
        &UpdateActionProgress($actionid,$curperc,"Created temp directory for subtemplate $sub");
        $curperc+=$percentpersubstep;

        local($result)=open(PFILE,">$tempdir/.ovftool");
        for $line (@configfile)
        {
          local($newline)=&FindAndReplace($line,%subinfo);
          print PFILE $newline;
        }
        close(PFILE);
        &UpdateActionProgress($actionid,$curperc,"Wrote settings file for subtemplate $sub");
        $curperc+=$percentpersubstep;

        my($configFile)=($configoption==1) ? "--configFile=$tempdir/.ovftool" : "" ;
        my($ovftoolcmdline)="cd $tempdir ; /usr/bin/ovftool $configFile /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE} $info{OVADESTINATION}";
        print "<LI>Command line = $ovftoolcmdline\n";
        if($subinfo{MAC} ne "")
        {
          print "<LI> MAC ADDRESS is now $subinfo{MAC}\n";

          my($cmdline)="mkdir $tempdir/ova ;  tar -C $tempdir/ova -xf /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE}";
          print "<LI>$cmdline";
          &UpdateActionProgress($actionid,$curperc,"Extracting ova file");
          local($result)=&RunCommand($cmdline,"Extracting ova file");
          if ($result)
          {
            #print"<LI>Result = $result"
            &UpdateActionProgress($actionid,-2,"Error extracting OVA file");
            return 2;
          }
          &UpdateActionProgress($actionid,$curperc,"Extracted ova file");
          $curperc+=$percentpersubstep;

          my($ovffile)=`ls -1 $tempdir/ova/*.ovf`;
          chomp($ovffile);
          print "<LI>ovffile = $ovffile";
          &UpdateActionProgress($actionid,$curperc,"ovf file is $ovffile");
          $curperc+=$percentpersubstep;

          my($newmac)=$subinfo{MAC};
          $newmac =~ s/-/:/g ;
           
          $tempovf="$tempdir/$newmac.ovf";
          &UpdateActionProgress($actionid,$curperc,"Adding MAC to ovf file");
          local($result)=&AddMacToFirstNetworkCard($ovffile,$tempovf,$newmac);
          if ($result != 0)
          {
             #print"<LI>Result = $result"
             &UpdateActionProgress($actionid,-2,"Error adding MAC to OVF file");
             return 2;
          }
          &UpdateActionProgress($actionid,$curperc,"Added MAC to ovf file");
          $curperc+=$percentpersubstep;

          my($cmdline)="sudo mv $ovffile $tempdir/; sudo mv $tempovf $ovffile";
          print "<LI>$cmdline";
          &UpdateActionProgress($actionid,$curperc,"Replacing ovf file");
          local($result)=&RunCommand($cmdline,"Replacing ovf file");
          if ($result)
          {
             #print"<LI>Result = $result"
             &UpdateActionProgress($actionid,-2,"Error Replacing ovf file");
             return 2;
          }
          &UpdateActionProgress($actionid,$curperc,"Replacing ovf file");
          $curperc+=$percentpersubstep;

          my($manifest)=`ls -1 $tempdir/ova/*.mf`;
          chomp($manifest);
          print "<LI>manifest = $manifest";
          &UpdateActionProgress($actionid,$curperc,"Manifest is $manifest");
          $curperc+=$percentpersubstep;

          my($shasum)=`shasum -a 256 $ovffile | awk '{print \$1}'`;
          chomp($shasum);
          my($ovfbase)=`basename $ovffile`;
          chomp($ovfbase);
          my($cmdline)="sudo sed -i -E 's,^(.*$ovfbase.*=\s*).*,\\1$shasum,g' $manifest";
          &UpdateActionProgress($actionid,$curperc,"Replacing shasum in manifest file");
          local($result)=&RunCommand($cmdline,"Replacing shasum in manifest file");
          if ($result)
          {
             &UpdateActionProgress($actionid,-2,"Error Replacing shasum in manifest file");
             return 2;
          }
          &UpdateActionProgress($actionid,$curperc,"Replacing shasum in manifest file");
          $curperc+=$percentpersubstep;

          my($basename)=`basename /var/public/smbmount/$info{OVAMOUNT}/$info{OVAFILE}`;
          chomp($basename);

          my($newovafile)="$tempdir/$basename";
          my($cmdline)="cd $tempdir/ova ; sudo tar -cf $newovafile *.ovf ; sudo mv *.ovf .. ; sudo tar -rf $newovafile * ; cd -";
          &UpdateActionProgress($actionid,$curperc,"Tarring into ova file $newovafile");
          local($result)=&RunCommand($cmdline,"Tarring into ova file");
          if ($result)
          {
             &UpdateActionProgress($actionid,-2,"Error tarring into OVA file");
             return 2;
          }
          &UpdateActionProgress($actionid,$curperc,"Tarred to ova file");
          $curperc+=$percentpersubstep;
          my($configFile)=($configoption==1) ? "--configFile=$tempdir/.ovftool" : "" ;
          $ovftoolcmdline="cd $tempdir ; /usr/bin/ovftool $configFile $newovafile $info{OVADESTINATION}";
          print "<LI>New ova file = $newovafile\n";
          print "<LI>Command line = $ovftoolcmdline\n";
        }
        $ovftoolcmdline=&FindAndReplace($ovftoolcmdline,%subinfo);
        print "<LI>Command line = $ovftoolcmdline\n";
        &UpdateActionProgress($actionid,30,"Built command line for subtemplate $sub");
        &UpdateActionProgress($actionid,$curperc,"Starting ovftool command for subtemplate $sub");
        $curperc+=$percentpersubstep;

        #my($result)=0;
        print "<LI>Command line = $ovftoolcmdline\n";
        local($result)=&RunCommand($ovftoolcmdline,"Running ovftool command for subtemplate $sub");
        if ($result)
        {
           #print"<LI>Result = $result" 
           &UpdateActionProgress($actionid,-2,"Error running ovftool command for subtemplate $sub");
           return 2;
        }
        &UpdateActionProgress($actionid,$curperc,"Deployed subtemplate $sub for template $template succesfully");
        $curperc+=$percentpersubstep;
      }
    }
  }
  &UpdateActionProgress($actionid,100,"Successfull");
}

sub CopyTemplate
{
  local($template)=$formdata{template};
  local(%info)=&GetTemplateInfo($template);

  print "<CENTER>\n";
  print "<H2>Copy Template $template</H2>\n";
  &PrintToolbar("Save","Cancel");
  print "<script language='javascript' src='/js/copytemplate.js'></script>\n";
  print "<script language='javascript' src='/js/validation.js'></script>\n";
  
  print "<FORM NAME=WIZARDFORM ACTION=\"uda3.pl\">\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=copy>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=template VALUE=$template>\n";
  print "<INPUT TYPE=HIDDEN NAME=OS VALUE=$info{OS}>\n";
  print "<INPUT TYPE=HIDDEN NAME=FLAVOR VALUE=$info{FLAVOR}>\n";
  print "<TABLE>\n";
  print "<TR><TD>Template Name</TD><TD><INPUT TYPE=TEXT NAME=NEWTEMPLATENAME VALUE=\"CopyOf$template\">\n";
  print "<TR><TD>Description</TD><TD><INPUT TYPE=TEXT NAME=NEWDESCRIPTION VALUE=\"$info{DESCRIPTION}\"></TD></TR>\n";
  print "<TR><TD>OS</TD><TD>$info{OS}</TD></TR>\n";
  print "<TR><TD>Flavor</TD><TD>$info{FLAVOR}</TD></TR>\n";
  print "<TR><TD>MAC</TD><TD><INPUT TYPE=TEXT NAME=NEWMAC VALUE=\"$info{MAC}\"></TD></TR>\n";
  local($publish)="";
  if ($info{PUBLISH} eq "ON")
  {
    $publish="CHECKED";
  }
  print "<TR><TD>Publish</TD><TD><INPUT TYPE=CHECKBOX NAME=PUBLISH $publish></TD></TR>\n";
  print "<TR><TD>Copy Subtemplates</TD><TD><INPUT TYPE=CHECKBOX NAME=COPYSUBTEMPLATES></TD></TR>\n";
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";

  return 0;
}

sub ApplyCopyTemplate
{
 local($orgtemplate)=$formdata{template};
 local($desttemplate)=$formdata{NEWTEMPLATENAME};
 local($description)=$formdata{NEWDESCRIPTION};
 local($mac)=$formdata{NEWMAC};
 local($os)=$formdata{OS};
 local($flavor)=$formdata{FLAVOR};
 local($publish)="ON";
 if (!defined($formdata{PUBLISH}))
 {
   $publish="OFF";
 }
 local($generatemac)="ON";
 if (!defined($formdata{GENERATEMAC}))
 {
   $generatemac="OFF";
 } 
  # Check The Template name first
  local($result)=&CheckTemplateName($desttemplate);
  if ($result)
  {
    return 1;
  }

 local(%info)=&GetTemplateInfo($orgtemplate);
 $info{TEMPLATE}=$desttemplate;
 $info{MAC}=$mac;
 $info{PUBLISH}=$publish;
 $info{DESCRIPTION}=$description;
 $info{OS}=$os;
 $info{FLAVOR}=$flavor;
 $info{GENERATEMAC}=$generatemac;

  if (defined(&{$info{OS}."_GetDefaultConfigFile1"}))
  {
    $info{CONFIGFILE1}=&{$info{OS}."_GetDefaultConfigFile1"}($desttemplate);
    if ($result) { return $result };
  }

  if (defined(&{$info{OS}."_GetDefaultConfigFile2"}))
  {
    $info{CONFIGFILE2}=&{$info{OS}."_GetDefaultConfigFile2"}($desttemplate);
    if ($result) { return $result };
  }

  if (defined(&{$info{OS}."_GetDefaultPublishDir"}))
  {
    $info{PUBLISHDIR}=&{$info{OS}."_GetDefaultPublishDir"}($desttemplate);
    if ($result) { return $result };
  }

  if (defined(&{$info{OS}."_GetDefaultPublishDir2"}))
  {
    $info{PUBLISHDIR2}=&{$info{OS}."_GetDefaultPublishDir2"}($desttemplate);
    if ($result) { return $result };
  }

  if (defined(&{$info{OS}."_GetDefaultPublishFile"}))
  {
    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($desttemplate);
    if ($result) { return $result };
  }

  if (defined(&{$info{OS}."_GetDefaultPublishFile2"}))
  {
    $info{PUBLISHFILE2}=&{$info{OS}."_GetDefaultPublishFile2"}($desttemplate);
    if ($result) { return $result };
  }

 if (defined($formdata{COPYSUBTEMPLATES}))
 {
   local($orgsubfile)=$TEMPLATECONFDIR."/$orgtemplate.sub";
   if ( -f $orgsubfile )
   {
     local($destsubfile)=$TEMPLATECONFDIR."/$desttemplate.sub";
     local($command)="cp $orgsubfile $destsubfile";
     local($result)=&RunCommand($command,"Copying $orgsubfile to $orgdestfile");
     if ($result)
     {
       &PrintError("Could not copy subtemplates for $desttemplate");
       return 1;
     }
   }
 }

 local($orgsubfile)=$TEMPLATECONFDIR."/$orgtemplate.ovo";
 if ( -f $orgsubfile )
 {
   local($destsubfile)=$TEMPLATECONFDIR."/$desttemplate.ovo";
   local($command)="cp $orgsubfile $destsubfile";
   local($result)=&RunCommand($command,"Copying $orgsubfile to $orgdestfile");
   if ($result)
   {
     &PrintError("Could not copy ovftool options for $desttemplate");
     return 1;
   }
 }

 $info{OVOFILE}=$TEMPLATECONFDIR."/$desttemplate.ovo" ;

 local($result)=&WriteTemplateInfo(%info);
 if ($result)
 {
   &PrintError("Could not Write Template info file for $desttemplate");
   return 1;
 }

 local($requirefile)=$OSDIR."/".$info{OS}.".pl";
 require $requirefile;
 local($result)=&{$info{OS}."_CopyTemplate"}($orgtemplate,$desttemplate,%info);
 if ($result)
 {
   &PrintError("Could not Copy $info{OS} related info for template $desttemplate");
   return 1;
 }

 local($result)=&PublishTemplate($desttemplate);
 if ($result) 
 { 
   &PrintError("Could not publish template $desttemplate");
   return 1;
 }
 local($result)=&WriteDefaultFile();
 if ($result) 
 { 
   &PrintError("Could not write default file");
   return 1;
 }
 
 &PrintSuccess("Copied template $orgtemplate to $desttemplate");

 return 0;
}


sub ApplyEditTemplate
{

 local($orgtemplate)=$formdata{template};
 local($template)=$formdata{NEWTEMPLATE};
 local($description)=$formdata{NEWDESCRIPTION};
 local($mac)=$formdata{NEWMAC};
 local($os)=$formdata{OS};
 local($flavor)=$formdata{NEWFLAVOR};
 local($pxepasswd)=$formdata{NEWPXEPASSWD};
 local($ovasource)=$formdata{NEWOVASOURCE};
 local($ovadestination)=$formdata{NEWOVADESTINATION};
 local($ovaconfig)=$formdata{NEWOVACONFIG};
 local($ovamount)=$formdata{NEWOVAMOUNT};
 local($ovafile)=$formdata{NEWOVAFILE};

 #print "<H1>$ovafile</H1>\n" ;

 local($publish)="ON";
 if (!defined($formdata{NEWPUBLISH}))
 {
   $publish="OFF";
 }
 local($generatemac)="ON";
 if (!defined($formdata{NEWGENERATEMAC}))
 {
   $generatemac="OFF";
 }
 local($separator)="MENU SEPARATOR";
 if (!defined($formdata{NEWSEPARATOR}))
 {
   $separator="#";
 }
 local(%info)=&GetTemplateInfo($orgtemplate);
 $info{TEMPLATE}=$template;
 $info{MAC}=$mac;
 $info{MAC}=~ s/\:/\-/g ;
 $info{PUBLISH}=$publish;
 $info{DESCRIPTION}=$description;
 $info{OS}=$os;
 $info{FLAVOR}=$flavor;
 $info{SEPARATOR}=$separator;
 $info{GENERATEMAC}=$generatemac;
 $info{OVASOURCE}=$ovasource;
 $info{OVADESTINATION}=$ovadestination;
 $info{OVAOPTIONS}=$ovaoptions;
 $info{OVAMOUNT}=$ovamount;
 $info{OVAFILE}=$ovafile;
 if ($pxepasswd ne "")
 {
   $info{PXEPASSWD}="menu passwd ".$pxepasswd;
 } else {
   $info{PXEPASSWD}="# no password";
 }

 local($result)=&WriteTemplateInfo(%info);
 if ($result) { return $result ; }

 local($subtemplates)=$formdata{SUBTEMPLATEINFO};
 local($result)=&SaveSubTemplateFile($template,$subtemplates);
 if ($result) { return $result ; }

 local($ovaconfig)=$formdata{OVAOPTIONS};
 local($result)=&SaveTemplateOvaConfig($template,$ovaconfig);
 if ($result) { return $result ; }

 local($requirefile)=$OSDIR."/".$info{OS}.".pl";
 require $requirefile;
 if (defined(&{$info{OS}."_ApplyConfigureTemplate"}))
 {
   local($result)=&{$info{OS}."_ApplyConfigureTemplate"}($template,%info);
   if ($result) { return $result ; }
 }

 if ($publish eq "ON")
 {
   local($result)=&PublishTemplate($template);
   if ($result) { return $result };
 } else {
   local($result)=&UnPublishTemplate($template);
   if ($result) { return $result };
 }

 if ($template ne $orgtemplate)
 {
   local($result)=&DeleteTemplate($orgtemplate);
   if ($result) { return $result };
 }

 local($result)=&WriteDefaultFile();
 if ($result) { return $result };

 return 0;
}

sub PublishAllTemplates
{
  local(%templates)=&GetTemplateHTMLConfig();
  local($overallresult)=0; 
  for $template (keys(%templates))
  {
    local($result)=&PublishTemplate($template);
    $overallresult+=$result;
  }
  local($result)=&WriteDefaultFile();
  $overallresult+=$result;
  return $overallresult;
}

sub UnPublishTemplate
{
  local($template)=shift;
  local(%info)=&GetTemplateInfo($template);

  for $infokey (keys(%info))
  {
    if ($infokey =~ /PUBLISHDIR[0-9]+/)
    {
      local($deletedir)=$info{$infokey};
      local($result)=&RunCommand("rm -rf $deletedir","Deleting $deletedir");
      if ($result)
      {
        return $result;
      }
    }
    if ($infokey =~ /PUBLISHEFIDIR[0-9]+/)
    {
      local($deletedir)=&FindAndReplace($info{$infokey},%info);
      local($result)=&RunCommand("rm -rf $deletedir","Deleting $deletedir");
      if ($result)
      {
        return $result;
      }
    }
  }

  local($result)=&RunCommand($command,"Removing publishdir $info{PUBLISHDIR1}");
  if ($result) { return $result; }

  local($result)=&DeleteTemplatePXEMenu($template);
  if ($result) { return $result; }

  local($requirefile)=$OSDIR."/".$info{OS}.".pl";
  require $requirefile;
  if (defined(&{$info{OS}."_UnPublishTemplate"}))
  {
    local($result)=&{$info{OS}."_UnPublishTemplate"}($template);
    if ($result) { return $result };
  } 

  return 0;
}

sub PublishTemplate
{
  local($template)=shift;
 
  local(%info)=&GetTemplateInfo($template);

  if ($info{PUBLISH} eq "ON")
  {
     # Create the publish directry for this template
     local($result)=&CreateDir($info{PUBLISHDIR1});
     if ($result)
     {
       &PrintError("Could not create directory $info{PUBLISHDIR1}");
       return 1;
     }

    local(%subinfo)=&GetAllSubTemplateInfo($template);

    local(@configfile)=&GetConfigFile($info{CONFIGFILE1});
    local(@indexes)=keys(%subinfo);
    if ($#indexes<0)
    {
       $info{SUBTEMPLATE}="default";
       local($publishfile)=&FindAndReplace($info{PUBLISHFILE1},%info);
       local($result)=open(PFILE,">$publishfile");
       for $line (@configfile)
       {
        local($newline)=&FindAndReplace($line,%info);
        print PFILE $newline;
       }
       close(PFILE);
    } else  {
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
     
         local($publishfile)=&FindAndReplace($subinfo{PUBLISHFILE1},%subinfo);
  
         # print "<LI>Current publishfile = $publishfile\n";
         local($result)=open(PFILE,">$publishfile");
         for $line (@configfile)
         {
           local($newline)=&FindAndReplace($line,%subinfo);
           print PFILE $newline;
         }
         close(PFILE);
        }
      }
    }

   if (defined(&{$info{OS}."_PublishTemplate"}))
   {
       local($result)=&{$info{OS}."_PublishTemplate"}($template);
       if ($result) { return $result };
   }

   if (defined(&{$info{OS}."_PublishEFITemplate"}))
   {
       local($result)=&{$info{OS}."_PublishEFITemplate"}($template);
       if ($result) { return $result };
   }

   local($result)=&WriteTemplatePXEMenu($template,%info);
   if ($result) { return $result };

   local($result)=&WriteTemplateEFIMenu($template,%info);
   if ($result) { return $result };
  }

  return 0;
}

sub DeleteTemplate
{
  local($template)=@_;
  local(%info)=&GetTemplateInfo($template);
  local($os)=$info{OS}; 
  local($requirefile)=$OSDIR."/".$os.".pl";
  require $requirefile;
  &{$os."_DeleteTemplate"}($template);

  for $infokey (keys(%info))
  {
    if ($infokey =~ /CONFIGFILE[0-9]+/)
    {
      local($deletefile)=$info{$infokey};
      &RunCommand("rm $deletefile","Deleting $deletefile");
    }
    if ($infokey =~ /OVOFILE=/)
    {
      local($deletefile)=$info{$infokey};
      &RunCommand("rm $deletefile","Deleting $deletefile");
    }
  }

  local($result)=&UnPublishTemplate($template);
  if ($result)
  {
     &PrintError("Could not unpublish template $template");
     return 1;
   }

  local($result)=&DeleteTemplateDatFile($template);
  if ($result)
  {
     &PrintError("Could not remove template dat file for template $template");
     return 1;
   }

  local($result)=&DeleteSubtemplateFile($template);
  if ($result)
  {
     &PrintError("Could not remove subtemplate file for $template");
     return 1;
  }

  local($result)=&WriteDefaultFile();
   if ($result)
   {
     &PrintError("Could not write default file");
     return 1;
   }

  return 0;
}

sub ConfigureTemplate
{
  local($template)=$formdata{template};
  local(%info)=&GetTemplateInfo($template);
  local($requirefile)=$OSDIR."/".$info{OS}.".pl";
  require $requirefile;
  print "<CENTER>\n";
  print "<H2>Configure template $template</H2>\n";
  &PrintToolbar("Save","Cancel");
  print "<BR>\n";
  print "<TABLE BORDER=0><TR><TD>\n";
  print "<TABLE WIDTH=600px HEIGHT=30px><TR CLASS=tabbed HEIGHT=30px>\n";
  print "<TD ALIGN=CENTER HEIGHT=30px ONCLICK=\"SelectTab(this);\" ID=general CLASS=tab><B>General</B></TD>\n";
  print "<TD ALIGN=CENTER HEIGHT=30px ONCLICK=\"SelectTab(this);\" ID=subtemplates CLASS=tab><B>Subtemplates</B></TD>\n";
  print "<TD ALIGN=CENTER HEIGHT=30px ONCLICK=\"SelectTab(this);\" ID=advanced CLASS=tab><B>Advanced</B></TD>\n";
  local($numtabs)=3;
  if (defined(&{$info{OS}."_ConfigureTemplate2"}))
  {
    print "<TD ALIGN=CENTER HEIGHT=30px ONCLICK=\"SelectTab(this);\" ID=advanced2 CLASS=tab><B>More...</B></TD>\n";
    $numtabs++;
  }
  if ($OVFTOOLINSTALLED)
  {
    print "<TD ALIGN=CENTER HEIGHT=30px ONCLICK=\"SelectTab(this);\" ID=ovf CLASS=tab><B>OVA</B></TD>\n";
    $numtabs++;
  }
  print "</TR>\n";
  print "</TABLE>\n";
  print "</TD></TR>\n";
  print "<TR><TD VALIGN=TOP CLASS=tabcontent>\n";
 # STYLE=\"border-style: none solid solid solid; border-width: thin\" >\n";
  print "<FORM NAME=CONFIGURETEMPLATEFORM ACTION=\"uda3.pl\" METHOD=POST>\n";
  print "<DIV ID=general_div STYLE=\"display:block\">\n";
  print "<script language='javascript' src='/js/configuretemplates.js'></script>\n";
  print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
  print "<script language='javascript' src='/js/validation.js'></script>\n";
  &PrintJavascriptArray("flavorarray",&GetOSFlavorList());
  # &PrintJavascriptArray("ovaarray",&GetOVAList());
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=template VALUE=$template>\n";
  print "<INPUT TYPE=HIDDEN NAME=OS VALUE=$info{OS}>\n";
  print "<INPUT TYPE=HIDDEN NAME=FLAVOR VALUE=$info{FLAVOR}>\n";
  print "<INPUT TYPE=HIDDEN NAME=OVASOURCE VALUE=$info{OVASOURCE}>\n";
  print "<INPUT TYPE=HIDDEN NAME=OVAMOUNT VALUE=$info{OVAMOUNT}>\n";
  print "<INPUT TYPE=HIDDEN NAME=OVAFILE VALUE=$info{OVAFILE}>\n";
  print "<TABLE>\n";
  print "<TR><TD>Template Name</TD><TD><INPUT TYPE=TEXT NAME=NEWTEMPLATE VALUE=\"$template\">\n";
  print "<TR><TD>Description</TD><TD><INPUT TYPE=TEXT NAME=NEWDESCRIPTION VALUE=\"$info{DESCRIPTION}\"></TD>
</TR>\n";
  print "<TR><TD>OS</TD><TD>$info{OS}</TD></TR>\n";
  # print "<TR><TD>Flavor</TD><TD>$info{FLAVOR}</TD></TR>\n";
  print "<TR><TD>Flavor</TD><TD><SELECT NAME=NEWFLAVOR ID=NEWFLAVOR></SELECT></TD></TR>\n";
  print "<TR><TD>MAC</TD><TD><INPUT TYPE=TEXT NAME=NEWMAC VALUE=\"$info{MAC}\"></TD></TR>\n";
  local($checked)="CHECKED";
  if ($info{GENERATEMAC} eq "OFF")
  {
    $checked="";
  }
  print "<TR><TD>Generate Mac-based PXE Boot Configuration(s)</TD><TD><INPUT TYPE=CHECKBOX NAME=NEWGENERATEMAC $checked></TD></TR>\n";
  local($checked)="CHECKED";
  if ($info{PUBLISH} eq "OFF")
  {
    $checked="";
  }
  print "<TR><TD>Publish</TD><TD><INPUT TYPE=CHECKBOX NAME=NEWPUBLISH $checked></TD></TR>\n";

  local($checked)="";
  if ($info{SEPARATOR} eq "MENU SEPARATOR")
  {
    $checked="CHECKED";
  }
  print "<TR><TD>PXE menu separator</TD><TD><INPUT TYPE=CHECKBOX NAME=NEWSEPARATOR $checked></TD></TR>\n";
  $info{PXEPASSWD}=~s/^menu passwd //g;
  if ($info{PXEPASSWD} =~ /^# no password/)
  {
    $info{PXEPASSWD}="";
  }
  print "<TR><TD>PXE password</TD><TD><INPUT TYPE=TEXT NAME=NEWPXEPASSWD VALUE=\"$info{PXEPASSWD}\"></TD></TR>\n";

  print "</TABLE>\n";
  print "</DIV>\n";
  print "<DIV ID=subtemplates_div STYLE=\"display:none\">\n";
  &ViewSubTemplates($template);
  print "</DIV>\n";
  print "<DIV ID=advanced_div STYLE=\"display:none\">\n";
  if (defined(&{$info{OS}."_ConfigureTemplate"}))
  {
    local($result)=&{$info{OS}."_ConfigureTemplate"}($template,%info);
    if ($result) { return $result; }
  }
  print "</DIV>\n";

  print "<DIV ID=advanced2_div STYLE=\"display:none\">\n";
  if (defined(&{$info{OS}."_ConfigureTemplate2"}))
  {
    local($result)=&{$info{OS}."_ConfigureTemplate2"}($template,%info);
    if ($result) { return $result; }
  }
  print "</DIV>\n";
  print "<DIV ID=ovf_div STYLE=\"display:none\">\n";
  #if ($OVFTOOLINSTALLED)
  #{
    local(@mountlist)=&GetMountList();;
    &PrintJavascriptArray("mountsarray",@mountlist);
    print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
    print "<script language='javascript' src='/js/treeova.js'></script>\n";
    print "<TABLE>\n";
    #print "<TR><TD>Source</TD><TD><SELECT NAME=NEWOVASOURCE ID=NEWOVASOURCE></SELECT></TD></TR>\n";
    print "<TR><TD VALIGN=TOP>Source</TD><TD><TABLE><TR><TD>Storage</TD><TD><SELECT NAME=NEWOVAMOUNT ID=NEWOVAMOUNT ONCHANGE=\"expandova('/')\"></SELECT></TD></TR>\n";
    print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=NEWOVAFILE ID=NEWOVAFILE SIZE=60 VALUE=\"$info{OVAFILE}\"></TD></TR>\n";
    print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR></TR></TABLE>\n";
    print "<TR><TD>Destination</TD><TD><INPUT TYPE=TEXT SIZE=50 ID=NEWOVADESTINATION NAME=NEWOVADESTINATION VALUE=\"$info{OVADESTINATION}\"></TD></TR>\n";
       
    if ($config{OVOFILE} eq "")
    {
      $config{OVOFILE}="$TEMPLATECONFDIR/$template.ovo";
    } 
  
    local(@kickstart)=&GetConfigFile($config{OVOFILE});
    print "<INPUT TYPE=HIDDEN NAME=OVOFILE VALUE=\"$config{OVOFILE}\">\n";
    print "<TR><TD VALIGN=TOP>Options</TD><TD><TEXTAREA NAME=OVAOPTIONS ROWS=20 COLS=60>" ;
    for $line (@kickstart)
    {
      print $line;
    }
    print "</TEXTAREA></TD></TR>\n";
    print "</TABLE>\n";
    print "</DIV>\n";
    print "</FORM>\n";
    print "</TD></TR></TABLE>";

    print "<script language='javascript'>\n";
    print "LoadValues(\"NEWOVAMOUNT\",mountsarray);\n";
    print "</script>\n";

    print "<script language=javascript>PreSelect(\"NEWOVAMOUNT\",\"$info{OVAMOUNT}\");</script>\n";
    print "<script language=javascript>UpdateOva(\"$info{OVAMOUNT}\",\"$info{OVAFILE}\");</script>\n";

    #print "<script language=javascript>expandova(\"\");</script>\n";
    #print "<script language='javascript'>LoadValues(\"NEWOVASOURCE\",ovaarray);</script>\n";
  #} else {
  #  print "</DIV>\n";
  #  print "</FORM>\n";
  #  print "</TD></TR></TABLE>";
  #}
  print "<script language='javascript'>ReloadIndexedValues(\"NEWFLAVOR\",flavorarray,\"$info{OS}\");</script>\n";
  print "<script language='javascript'>PreSelect(\"NEWFLAVOR\",\"$info{FLAVOR}\");</script>\n";

  print "<script language='javascript'>SelectTab(document.getElementById('general'));</script>\n";
  return 0;
}

sub ConfigureTemplateAdvanced
{
  local($template)=$formdata{template};
  local(%info)=&GetTemplateInfo($template);

  local($os)=$info{OS};
  local($requirefile)=$OSDIR."/".$os.".pl";
  require $requirefile;
  &{$os."_ConfigureTemplate"}($template,%info);

  return 0;
}

sub WriteTemplatePXEMenu
{
  local($template,%info)=@_;

  local($os)=$info{OS};
  local($requirefile)=$OSDIR."/".$os.".pl";
  require $requirefile;
  local($result)==&{$os."_WriteTemplatePXEMenu"}($template);
  return 0;
}


sub DeleteTemplatePXEMenu
{
  local($template)=@_;
  local($templatepxefile)=$PXETEMPLATEDIR."/$template.menu";
  local($result)=&RunCommand("rm -f $templatepxefile");
  return $result;
}

sub ViewSubTemplates
{
  local($template)=shift;
  print "<CENTER>\n";
  # print "<script language='javascript' src='/js/subtemplates.js'></script>\n";
  print "<script language='javascript' src='/js/validatesubtemplates.js'></script>\n";
  print "<DIV ID=SUBTEMPLATEEDITDIV STYLE='display:block'>\n";
  &PrintToolbar("Edit","Download");
  print "<BR><BR>\n";
  print " <TABLE BORDER=1>\n";
  local(%templatesort)=&GetSubTemplateSort($template);
  local(%templateconfig)=&GetSubTemplateHTMLConfig($template);
  local(@fileinfo)=&GetSubTemplateFile($template);
  print "<TR CLASS=tableheader>$templateconfig{__HEADER__}</TR>\n";
  for $curtemplateconfig (sort(keys(%templatesort)))
  {
      print "<TR onclick='SelectRow(this)' ID=$curtemplateconfig>$templateconfig{$templatesort{$curtemplateconfig}}</TR>\n";
  }
  print "</TABLE>\n";
  print "</DIV>\n";
  print "<DIV ID=SUBTEMPLATEMANUALDIV STYLE='display:none'>\n";
  print "<H3>Subtemplate manual edit</H3>\n";
  print "<TEXTAREA WRAP=OFF ROWS=20 COLS=60 NAME=SUBTEMPLATEINFO>\n";
  for $line (@fileinfo)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  &PrintToolbar("Back");
  print "</DIV>\n";
  print "</CENTER>\n";
 return 0;
}

sub EditSubTemplates
{
  local($template)=shift;
  local(@fileinfo)=&GetSubTemplateFile($template);
  print "<CENTER>\n";
  print "<DIV ID=SUBTEMPLATEEDITDIV STYLE='display:block'>\n";
  &PrintToolbar("Upload","Download");
  # print "<script language='javascript' src='/js/subtemplates.js'></script>\n";
  # print "<script language='javascript' src='/js/editsubtemplates.js'></script>\n";
  # print "<FORM NAME=SUBTEMPLATELISTFORM METHOD=POST ACTION=\"uda3.pl\">\n";
  # print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
  # print "<INPUT TYPE=HIDDEN NAME=action VALUE=subtemplate>\n";
  # print "<INPUT TYPE=HIDDEN NAME=template VALUE=$template>\n";
  # print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<TEXTAREA WRAP=OFF ROWS=30 COLS=60 NAME=SUBTEMPLATEINFO>";
  for $line (@fileinfo)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  print "</DIV>\n";
  print "<DIV ID=SUBTEMPLATEUPLOADDIV STYLE='display:none'>\n";
  print "<H3>Subtemplate file upload</H3>\n";
  print "Browse for the file to upload and click Save to start the upload and save all the change made in the configration<BR><BR>\n";
  print "Warning: manual changes made in the subtemplate configuration tab will be lost!<BR><BR>\n";
  print "<INPUT TYPE=FILE NAME=SUBTEMPLATEBROWSE VALUE=Browse>\n";
  print "<BR><BR>\n";
  &PrintToolbar("Back");
  print "</DIV>\n";
  # print "</FORM>\n";
  return 0;
}

sub SaveSubTemplates
{
  local($template)=shift;
  local($info)=$formdata{SUBTEMPLATEINFO};
  &SaveSubTemplateFile($template,$info);
  return 0;
}

sub CopySubTemplates
{
  local($orgtemplate,$desttemplate)=@_;
  local($orgfile)=
  local(@fileinfo)=&GetSubTemplateFile($orgtemplate);
  &SaveSubTemplateFile($desttemplate,$info);
  return 0;
}

sub DownloadSubTemplates
{
  local($template)=@_;
  local($subtemplatefile)="$TEMPLATECONFDIR/$template.sub";
  local($result)=open(STFILE,$subtemplatefile);
  local(@thefile)=<STFILE>;
  close(STFILE);
  print "Content-Type:application/x-download\n";  
  print "Content-Disposition:attachment;filename=$template.sub\n\n";
  print @thefile;
}


sub WriteTemplatePXEMenu
{
  local($template)=shift;
  local($passwordenabled)=0;
  local(%info)=&GetTemplateInfo($template);
  local(%subs)=&GetAllSubTemplateInfo($template);

  local(%subsort)=&GetSubTemplateSort($template);
  local(@sublist)=keys(%subs);

  local($templatepxefile)=$PXETEMPLATEDIR."/$template.menu";

  local($result)=opendir(NEWDIR,"$PXETEMPLATEDIR");
  while($newfn=readdir(NEWDIR))
  {
     if ($newfn =~ /^$template\.([0-9]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})$/)
     {
       # print ("<LI>Removing file $PXETEMPLATEDIR/$newfn\n");
       &RunCommand("rm $PXETEMPLATEDIR/$newfn","Removing Mac template file $PXETEMPLATEDIR/$newfn");
     }
     if ($newfn =~ /^$template\.$/)
     {
       # print ("<LI>QnD Removing $PXETEMPLATEDIR/$newfn\n");
       &RunCommand("rm $PXETEMPLATEDIR/$newfn","Removing QnD template mac file $PXETEMPLATEDIR/$newfn");
     }

   }

  local($headerline)=$subs{__HEADER__};
  if ($#sublist > 0)
  {
    local($result)=open(PXEFILE,">$templatepxefile");

    local(@menuitem)=&GetConfigFile($PXESUBMENUHEADER);
    for $itemline (@menuitem)
    {
      local($newline)=&FindAndReplace($itemline,%info);
      print PXEFILE $newline ;
    }

    close(PXEFILE);

   for $cursubindex (sort(keys(%subsort)))
   {
     $item=$subsort{$cursubindex};
     if ($item ne "__HEADER__")
     {
       local(%subinfo)=&GetSubTemplateInfo($headerline,$subs{$item},%info);
       local($kernel)=&FindAndReplace($subinfo{KERNEL},%subinfo);
       local($append)=&FindAndReplace($subinfo{CMDLINE},%subinfo);
       local($result)=open(PXEFILE,">>$templatepxefile");
       local(@menuitem)=&GetConfigFile($PXESUBMENUITEM);
       for $itemline (@menuitem)
       {
         local($oldline)="";
         while ($oldline ne $itemline)
         {
           $oldline=$itemline;
           $itemline=&FindAndReplace($itemline,%subinfo);
         }
         print PXEFILE $itemline ;
       }
       close(PXEFILE);

       if (defined($subinfo{MAC}) && $subinfo{MAC} ne "")
       {
         my($newmac)=$subinfo{MAC};
         $newmac=~s/:/-/g;
         local($MACFILE)=$PXETEMPLATEDIR."/".$subinfo{TEMPLATE}.".01-".$newmac ;
         local($result)=open(MF,">$MACFILE");
         print MF "MENU TITLE $item\n";
         print MF "DEFAULT $item\n";
         print MF "TIMEOUT 10\n";
         print MF "LABEL $item\n";
         print MF "  MENU LABEL default\n";
         print MF "  KERNEL $kernel\n";
         print MF "  APPEND $append\n";
         close(MF);
       }
     }
   }
 } else {
   $info{SUBTEMPLATE}="default";
   local($kernel)=&FindAndReplace($info{KERNEL},%info);
   local($append)=&FindAndReplace($info{CMDLINE},%info);
   local($result)=open(PXEFILE,">$templatepxefile");
   print PXEFILE "MENU TITLE Template $template\n";
   print PXEFILE "\n";
   print PXEFILE "DEFAULT default\n";
   print PXEFILE "TIMEOUT 1\n";
   print PXEFILE "LABEL default\n";
   print PXEFILE "  MENU LABEL default\n";
   if ($passwordenabled == 1)
   {
     print PXEFILE "  MENU PASSWD\n";
   }
   print PXEFILE "  KERNEL $kernel\n";
   print PXEFILE "  APPEND $append\n";
   close(PXEFILE);

  if (defined($info{MAC}) && $info{MAC} ne "")
  {
    my($newmac)=$info{MAC};
    $newmac=~s/:/-/g;
    local($MACFILE)=$PXETEMPLATEDIR."/".$info{TEMPLATE}.".01-".$newmac ;
    local($result)=open(MF,">$MACFILE");
    print MF "DEFAULT default\n";
    print MF "TIMEOUT 10\n";
    print MF "LABEL default\n";
    print MF "  MENU LABEL default\n";
    print MF "  KERNEL $kernel\n";
    print MF "  APPEND $append\n";
    close(MF);
  }
 }
  return 0
}

sub WriteTemplateEFIMenu
{
  local($template)=shift;
  local($passwordenabled)=0;
  local(%info)=&GetTemplateInfo($template);
  local(%subs)=&GetAllSubTemplateInfo($template);

  local(%subsort)=&GetSubTemplateSort($template);
  local(@sublist)=keys(%subs);

  local($templateefifile)=$EFITEMPLATEDIR."/$template/template.ipxe";

  local($tpldir)="$EFITEMPLATEDIR/$template";
  local($result)=&CreateDir($tpldir);
  if ($result) { return 2; }

  local($stpldir)="$EFITEMPLATEDIR/$template/subtemplates";
  local($result)=&CreateDir($stpldir);
  if ($result) { return 2; }

  local($macdir)="$EFITEMPLATEDIR/$template/macs";
  local($result)=&CreateDir($macdir);
  if ($result) { return 2; }

  local($result)=opendir(NEWDIR,$macdir);
  while($newfn=readdir(NEWDIR))
  {
     if ($newfn =~ /^([0-9]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})\.ipxe$/)
     {
       #print ("<LI>Removing file $macdir/$newfn\n");
       &RunCommand("rm $macdir/$newfn","Removing Mac template file $macdir/$newfn");
     }
     if ($newfn =~ /^\.ipxe$/)
     {
       #print ("<LI>QnD Removing $macdir/$newfn\n");
       &RunCommand("rm $macdir/$newfn","Removing QnD template mac file $macdir/$newfn");
     }
  }

  local($headerline)=$subs{__HEADER__};
  if ($#sublist > 0)
  {
   local($result)=open(EFIFILE,">$templateefifile");
   local(@menuitem)=&GetConfigFile($IPXESUBMENUHEADER);
   for $itemline (@menuitem)
   {
     local($newline)=&FindAndReplace($itemline,%info);
     print EFIFILE $newline ;
   }

   for $cursubindex (sort(keys(%subsort)))
   {
     $item=$subsort{$cursubindex};
     if ($item ne "__HEADER__")
     {
       local(%subinfo)=&GetSubTemplateInfo($headerline,$subs{$item},%info);
       print EFIFILE "item $item $item\n"
     }
   }

   local(@menuitem)=&GetConfigFile($IPXESUBMENUFOOTER);
   for $itemline (@menuitem)
   {
     local($newline)=&FindAndReplace($itemline,%info);
     print EFIFILE $newline ;
   }

   for $cursubindex (sort(keys(%subsort)))
   {
     $item=$subsort{$cursubindex};
     if ($item ne "__HEADER__")
     {
       local(%subinfo)=&GetSubTemplateInfo($headerline,$subs{$item},%info);
       print EFIFILE "\n:$item\n";
       local($chain)="/ipxe/templates/[TEMPLATE]/subtemplates/[SUBTEMPLATE].ipxe";
       local($newchain)=&FindAndReplace($chain,%subinfo);
       print EFIFILE "chain $newchain\n";
       print EFIFILE "goto start\n\n";

       if (defined($subinfo{MAC}) && $subinfo{MAC} ne "")
       {
         my($newmac)=$subinfo{MAC};
         $newmac=~s/:/-/g;
         local($MACFILE)=$macdir."/01-".$newmac.".ipxe" ;
         local($result)=open(MF,">$MACFILE");
         print MF "#!ipxe\n";
         print MF "chain $newchain\n";
         close(MF);
       }
     }
   }

   close(EFIFILE);

 } else {
   # print "<LI>NO subtemplates detected writing default file $templateefifile\n";
   $info{SUBTEMPLATE}="default";
   local($result)=open(EFIFILE,">$templateefifile");
   print EFIFILE "#!ipxe\n";
   local($chain)="/ipxe/templates/[TEMPLATE]/subtemplates/[SUBTEMPLATE].ipxe";
   local($newchain)=&FindAndReplace($chain,%info);
   print EFIFILE "chain $newchain\n";
   close(EFIFILE);

   if (defined($info{MAC}) && $info{MAC} ne "")
   {
      my($newmac)=$info{MAC};
      $newmac=~s/:/-/g;
      local($MACFILE)=$macdir."/01-".$newmac.".ipxe" ;
      local($result)=open(MF,">$MACFILE");
      print MF "#!ipxe\n";
      print MF "chain $newchain\n";
      close(MF);
   }
 }
  return 0
}

1;
