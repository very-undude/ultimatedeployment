#!/usr/bin/perl

my($BCDFILE)=shift;
my($WIMPATH)=shift;
my($SDIPATH)=shift;
my($STARTOPTIONS)=shift;
my($HIVEXSH)="/usr/bin/hivexsh";
my(%guids)=("bootmgr" => "{9dea862c-5cdd-4e70-acc1-f32b344d4795}",
            "ramdiskoptions","{ae5534e0-a924-466c-b836-758539a3ee3a}");
my($newguid)="{65c31250-afa2-11df-8045-000c29f37d88}";

sub Usage()
{
  print "$0 <bcdfile> <wimpath> <sdipath> [startoptions]\n";
  exit 1;
}

if ($BCDFILE eq "" || $WIMPATH eq "" || $SDIPATH eq "")
{
  &Usage();
}
$WIMPATH =~ s|/|\\|g;
$SDIPATH =~ s|/|\\|g;


sub Cleanup
{
 local($bcd)=shift;
 local($TEMPFILE1)="/tmp/bcdtemp1.$$";
 local($TEMPFILE2)="/tmp/bcdtemp2.$$";
 open(TEMP,">$TEMPFILE1") || die "Cannot open tempfile";
 print TEMP "cd Objects\n";
 print TEMP "ls\n";
 close(TEMP);

 local(@objects)=`$HIVEXSH $bcd -f $TEMPFILE1`;

  unlink($TEMPFILE1);

 open(TEMP2,">$TEMPFILE2");
 print TEMP2 "cd Objects\n";
 for $object (@objects)
 {
  chomp($object);
  # print "Adding Removing Object $object\n";
  print TEMP2 "cd $object\n";
  print TEMP2 "del\n";
 }
 print TEMP2 "commit\n";
 close(TEMP2);
 
 local(@result)=`$HIVEXSH -w $bcd -f $TEMPFILE2`;
 if ($? != 0)
 {
    print("Error Cleaning up BCD file $bcd\n");
   return 1;
 }
 unlink($TEMPFILE2);
 return 0;
}

sub CreateGuid
{
  my($bcdfile)=shift;
  my($guid)=shift;
  my($type)=shift;
  
 local($TEMPFILE3)="/tmp/bcdtemp3.$$";
 open(TEMP,">$TEMPFILE3") || die "Cannot open tempfile";
 print TEMP "cd Objects\n";
 print TEMP "add $guid\n";
 print TEMP "cd $guid\n";
 print TEMP "add Description\n";
 print TEMP "cd Description\n";
 print TEMP "setval 1\n";
 print TEMP "Type\n";
 print TEMP "dword:$type\n";
 print TEMP "cd ..\n";
 print TEMP "add Elements\n";
 print TEMP "commit\n";
 close(TEMP);
 
 local(@result)=`$HIVEXSH -w $bcdfile -f $TEMPFILE3`;
 if ($? != 0)
 {
    print("Error adding guid $guid with type $type to $bcdfile\n");
    return 1;
 }
 unlink($TEMPFILE3);
  return 0;
}

sub AddElement()
{
  my($bcdfile)=shift;
  my($guid)=shift;
  my($element)=shift;
  my($value)=shift;

 local($TEMPFILE4)="/tmp/bcdtemp4.$$";
 open(TEMP,">$TEMPFILE4") || die "Cannot open tempfile";
 print TEMP "cd Objects\n";
 print TEMP "cd $guid\n";
 print TEMP "cd Elements\n";
 print TEMP "add $element\n";
 print TEMP "cd $element\n";
 print TEMP "setval 1\n";
 print TEMP "Element\n";
 print TEMP "$value\n";
 print TEMP "commit\n";
 close(TEMP);

 local(@result)=`$HIVEXSH -w $bcdfile -f $TEMPFILE4`;
 if ($? != 0)
 {
    print("Error adding Element $element with value $value to guid $guid with type in $bcdfile\n");
    return 1;
 }
 unlink($TEMPFILE4);
  return 0;
}

sub DecToHex
{
  my($val)=shift;
  my($hexval)=sprintf("%x",$val);
  return $hexval;
}

sub Guids2MultiSZ
{
  my(@guidlist)=@_;
  my($multisz)="hex:7:";
  for $myguid (@guidlist)
  {
    my(@chararray)=split(undef,$myguid);
    for $mychar (@chararray)
    {
      $multisz.=",".&DecToHex(ord($mychar));
      $multisz.=",00";
    }
    $multisz.=",00,00";
  }
  $multisz.=",00,00";
  return $multisz;
}

sub Path2Binary
{
  my($path)=shift;
  my($binary)="";
  my(@chararray)=split(undef,$path);
  for $mychar (@chararray)
  {
    $binary.=",".&DecToHex(ord($mychar)).",00";
  }
  return $binary;
}

sub Guid2Binary
{
  my($guid)=shift;
  my($binary)="";
  my(@chararray)=split(undef,$guid);
 
  $binary.=$chararray[7];
  $binary.=$chararray[8];
  $binary.=",";
  $binary.=$chararray[5];
  $binary.=$chararray[6];
  $binary.=",";
  $binary.=$chararray[3];
  $binary.=$chararray[4];
  $binary.=",";
  $binary.=$chararray[1];
  $binary.=$chararray[2];
  $binary.=",";
  $binary.=$chararray[12];
  $binary.=$chararray[13];
  $binary.=",";
  $binary.=$chararray[10];
  $binary.=$chararray[11];
  $binary.=",";
  $binary.=$chararray[17];
  $binary.=$chararray[18];
  $binary.=",";
  $binary.=$chararray[15];
  $binary.=$chararray[16];
  $binary.=",";
  $binary.=$chararray[20];
  $binary.=$chararray[21];
  $binary.=",";
  $binary.=$chararray[22];
  $binary.=$chararray[23];
  $binary.=",";
  $binary.=$chararray[25];
  $binary.=$chararray[26];
  $binary.=",";
  $binary.=$chararray[27];
  $binary.=$chararray[28];
  $binary.=",";
  $binary.=$chararray[29];
  $binary.=$chararray[30];
  $binary.=",";
  $binary.=$chararray[31];
  $binary.=$chararray[32];
  $binary.=",";
  $binary.=$chararray[33];
  $binary.=$chararray[34];
  $binary.=",";
  $binary.=$chararray[35];
  $binary.=$chararray[36];

  return $binary;
}

sub MyLength
{
  my($path)=shift;
  my($add)=shift;
  my($result)=$add+(2*length($path));
  return DecToHex($result);
}


print "BCDfile = $BCDFILE\n";

&Cleanup($BCDFILE);

print "Creating Bootmgr Object\n";
&CreateGuid($BCDFILE,$guids{bootmgr},"0x10100002");
&AddElement($BCDFILE,$guids{bootmgr},"25000004","hex:3:1e,00,00,00,00,00,00,00");
&AddElement($BCDFILE,$guids{bootmgr},"12000004","string:Windows Boot Manager");
&AddElement($BCDFILE,$guids{bootmgr},"24000001",&Guids2MultiSZ($newguid));

print "Creating New Object\n";
&CreateGuid($BCDFILE,$newguid,"0x10200003");
&AddElement($BCDFILE,$newguid,"12000004","string:Windows PE");
&AddElement($BCDFILE,$newguid,"22000002","string:\\Windows");
&AddElement($BCDFILE,$newguid,"26000010","hex:3:01");
&AddElement($BCDFILE,$newguid,"26000022","hex:3:01");
&AddElement($BCDFILE,$newguid,"11000001","hex:3:".Guid2Binary($guids{ramdiskoptions}).",00,00,00,00,01,00,00,00,".&MyLength($WIMPATH,126).",00,00,00,00,00,00,00,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,".&MyLength($WIMPATH,86).",00,00,00,05,00,00,00,05,00,00,00,00,00,00,00,48,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00".&Path2Binary($WIMPATH)."00,00"); 
&AddElement($BCDFILE,$newguid,"21000001","hex:3:".Guid2Binary($guids{ramdiskoptions}).",00,00,00,00,01,00,00,00,".&MyLength($WIMPATH,126).",00,00,00,00,00,00,00,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,".&MyLength($WIMPATH,86).",00,00,00,05,00,00,00,05,00,00,00,00,00,00,00,48,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00".&Path2Binary($WIMPATH)."00,00"); 

if ($STARTOPTIONS ne "")
{
  &AddElement($BCDFILE,$newguid,"12000030","string:".$STARTOPTIONS);
}

print "Creating Ramdisk Options\n";
&CreateGuid($BCDFILE,$guids{ramdiskoptions},"0x30000000");
&AddElement($BCDFILE,$guids{ramdiskoptions},"12000004","string:Ramdisk Options");
&AddElement($BCDFILE,$guids{ramdiskoptions},"32000004","string:".$SDIPATH);
&AddElement($BCDFILE,$guids{ramdiskoptions},"31000003","hex:3:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,05,00,00,00,00,00,00,00,48,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00");

print "Succesfully updates $BCDFILE\n";
