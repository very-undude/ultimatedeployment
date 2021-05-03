#!/usr/bin/perl

require "general.pl";

sub GetWinPEConfig
{
  local(%drivers)=();
  opendir(WPEC,$WINPECONFDIR);
  while($filename=readdir(WPEC))
  {
    if ($filename ne "." && $filename ne "..")
    {
      local($ddirname)=$WINPECONFDIR."/".$filename;
      if ( -d $ddirname)
      {
        local($driverdat)=$ddirname."/driver.dat";
        if( -f $driverdat)
        {
           open(DD,"<$driverdat");
           while(<DD>)
           {
                 local($line)=$_;
                 if ( $line =~ /^\s*([A-Za-z0-9]+)\s*=\s*(.*)$/)
                 {
                   $drivers{$filename}{$1}=$2;
                 }
           }
           close(DD);
        }
      }
    }
  }
  closedir(WPEC);
  return %drivers;
}


sub WinPEPrintChecklist
{

  local($flavor,%flavorinfo)=@_;

  print "<CENTER>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/winpetablesort.js'></script>\n";
  # &PrintToolbar("Up","Down","Debug");
  &PrintToolbar("Up","Down");
  print " <TABLE BORDER=1 ID=winpedrvtable>\n";
  print "<TR CLASS=tableheader><TD></TD><TD>Name</TD><TD>Description</TD><TD>Inf filename</TD><TD>Sys Filename</TD></TR>\n";

  local(@checkeddrivers)=split(";",$flavorinfo{ACTIVEDRIVERS});
  local(@sorteddrivers)=split(";",$flavorinfo{SORTEDDRIVERS});

  local(%drivers)=&GetWinPEConfig();
  local($sortedhash)=();
  for $longdriver (@sorteddrivers)
  {
    if ($longdriver =~ /WINPEDRV_(.*)/)
    {
      local($driver)=$1;
      if(defined($drivers{$driver}))
      {
        print "<TR ID=$drivers{$driver}{NAME} ONCLICK=\"SelectRow(this)\"><TD><INPUT TYPE=CHECKBOX NAME=WINPEDRV_$driver ID=WINPEDRV_$driver></TD><TD>$driver</TD><TD>$drivers{$driver}{DESCRIPTION}</TD><TD>$drivers{$driver}{FILE1}</TD><TD>$drivers{$driver}{FILE2}</TD></TR>\n";
      }
      $sortedhash{$driver}=TRUE;
    }
  }

  for $newdriver (keys(%drivers))
  {
     if(!defined($sortedhash{$newdriver}))
     {
        print "<TR ID=$drivers{$newdriver}{NAME} ONCLICK=\"SelectRow(this)\"><TD><INPUT TYPE=CHECKBOX NAME=WINPEDRV_$newdriver ID=WINPEDRV_$newdriver></TD><TD>$newdriver</TD><TD>$drivers{$newdriver}{DESCRIPTION}</TD><TD>$drivers{$newdriver}{FILE1}</TD><TD>$drivers{$newdriver}{FILE2}</TD></TR>\n";
       push(@sorteddrivers,"WINPEDRV_$newdriver");
     }
  }
  
  print ("<INPUT TYPE=HIDDEN NAME=activedrivers ID=activedrivers VALUE=\"".join(";",@checkeddrivers)."\">");
  print ("<INPUT TYPE=HIDDEN NAME=sorteddrivers ID=sorteddrivers VALUE=\"".join(";",@sorteddrivers)."\">");
  print (" <script language='javascript'>selectactivedrivers();</script>");

}

sub WinPE
{
  print "<CENTER>\n";
  print "<H2>Windows PE Driver Database</H2>\n";
  &PrintToolbar("Add","Delete","Edit");
  print "<BR><BR>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/winpe.js'></script>\n";
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Name</TD><TD>Description</TD><TD>File 1</TD><TD>File 2</TD></TR>\n";
  local(%drivers)=&GetWinPEConfig();
  for $driver (keys(%drivers))
  {
    print "<TR onclick='SelectRow(this)' ID=$drivers{$driver}{NAME}><TD>$drivers{$driver}{NAME}</TD><TD>$drivers{$driver}{DESCRIPTION}</TD><TD>$drivers{$driver}{FILE1}</TD><TD>$drivers{$driver}{FILE2}</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
}

sub EditWinPEDriver
{

 local($drivername)=$formdata{driver};
 local(%drivers)=&GetWinPEConfig();
 local($driverdir)=$WINPECONFDIR."/".$drivername;
 local(@drvload)=&GetConfigFile($driverdir."/".$drivers{$drivername}{DRVLOAD});

 print "<CENTER>\n";
 print "<H2>Edit Windows PE Driver</H2>\n";
 print "<script language='javascript' src='/js/winpedrv.js'></script>\n";
 print "<FORM NAME=WIZARDFORM ENCTYPE=\"multipart/form-data\" METHOD=\"POST\" ACTION=\"/cgi-bin/apply_winpedrv.cgi\">\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OLDNAME VALUE=\"$drivername\">\n";
 print "<INPUT TYPE=HIDDEN NAME=OLDFILE1 VALUE=\"$drivers{$drivername}{FILE1}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=OLDFILE2 VALUE=\"$drivers{$drivername}{FILE2}\">\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Name</TD><TD COLSPAN=2><INPUT TYPE=TEXT NAME=NAME SIZE=15 VALUE=\"$drivername\"></TD></TR>\n";
 print "<TR><TD>Description</TD><TD COLSPAN=2><INPUT TYPE=TEXT NAME=DESCRIPTION SIZE=60 VALUE=\"$drivers{$drivername}{DESCRIPTION}\"></TD></TR>\n";
 print "<TR><TD>File 1</TD><TD><INPUT TYPE=RADIO NAME=RADIOFILE1 VALUE=CURRENT CHECKED> $drivers{$drivername}{FILE1}</TD><TD><INPUT TYPE=RADIO NAME=RADIOFILE1 VALUE=NEW><INPUT TYPE=FILE NAME=FILE1></TD></TR>\n";
 print "<TR><TD>File 2</TD><TD><INPUT TYPE=RADIO NAME=RADIOFILE2 VALUE=CURRENT CHECKED>$drivers{$drivername}{FILE2}</TD><TD><INPUT TYPE=RADIO NAME=RADIOFILE2 VALUE=NEW><INPUT TYPE=FILE NAME=FILE2 VALUE=\"\"></TD></TR>\n";

 print "<TR><TD VALIGN=TOP>Driver Load script</TD><TD COLSPAN=2>";
  print "<TEXTAREA WRAP=OFF NAME=DRVLOAD ROWS=20 COLS=60>";
  for $line (@drvload)
  {
    print $line;
  }
 print "</TEXTAREA></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
 return result;
}

sub AddWinPEDriver
{
 print "<CENTER>\n";
 print "<H2>Add Windows PE Driver</H2>\n";
 print "<script language='javascript' src='/js/winpedrv.js'></script>\n";
 print "<FORM NAME=WIZARDFORM ENCTYPE=\"multipart/form-data\" METHOD=\"POST\" ACTION=\"/cgi-bin/upload_winpedrv.cgi\">\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 &PrintToolbar("Upload","Cancel");
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Name</TD><TD><INPUT TYPE=TEXT NAME=NAME SIZE=15 VALUE=\"\"></TD></TR>\n";
 print "<TR><TD>Description</TD><TD><INPUT TYPE=TEXT NAME=DESCRIPTION SIZE=60 VALUE=\"\"></TD></TR>\n";
 print "<TR><TD>File 1</TD><TD><INPUT TYPE=FILE NAME=FILE1></TD></TR>\n";
 print "<TR><TD>File 2</TD><TD><INPUT TYPE=FILE NAME=FILE2></TD></TR>\n";
 print "<TR><TD>Load script</TD><TD><TEXTAREA NAME=DRVLOAD>drvload \%1</TEXTAREA></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
 return result;
}

sub DeleteWinPEDriver
{

  local($drivername)=$formdata{driver};
  local(%drivers)=&GetWinPEConfig();
  if (defined($drivers{$drivername}))
  {
    local($command)="rm -rf $WINPECONFDIR/$drivername";
    local($result)=&RunCommand($command,"Removing driver $drivername");
    if ($result)
    {
      &PrintError("Could not delete driver $drivername \n");
      return 1;
    } else {
      &WinPE();
      # &PrintSuccess("Windows PE Driver $drivername removed succesfully");
    }
  } else {
    &PrintError("Driver $drivername not found\n");
  }

}

1;
