function PushButton(MyButton)
{
    
    if ( MyButton.id == 'Edit' )
    {
      document.getElementById('SUBTEMPLATEEDITDIV').style.display='none';
      document.getElementById('SUBTEMPLATEMANUALDIV').style.display='block';
    }
    if ( MyButton.id == 'Back' )
    {
      document.getElementById('SUBTEMPLATEEDITDIV').style.display='block';
      document.getElementById('SUBTEMPLATEMANUALDIV').style.display='none';
    }
    if ( MyButton.id == 'Download' )
    {
      template=document.CONFIGURETEMPLATEFORM.template.value;
      window.location="download.cgi?type=subtemplate&template=" + template;
    }
    if ( MyButton.id == 'Save' )
    {
      if (document.getElementById("winpedrvtable") != null)
      {
        setactivedrivers();
        setdriversort();
      }
      if (!ValidateVarName(document.CONFIGURETEMPLATEFORM.NEWTEMPLATE.value,"Template Name"))
      {
        return false;
      }
      if (ValidateSubtemplates(document.CONFIGURETEMPLATEFORM.SUBTEMPLATEINFO))
      {
        document.CONFIGURETEMPLATEFORM.action.value="save";
        document.CONFIGURETEMPLATEFORM.submit();
      }
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.CONFIGURETEMPLATEFORM.action.value="list";
      document.CONFIGURETEMPLATEFORM.submit();
    }
    //if ( MyButton.id == 'Debug' )
    //{
    //   setactivedrivers();
    //   setdriversort();
    //   debugdrivers();
    //   return 0;
    //}
    if ( MyButton.id == 'Up' )
    {
      moverow('up');
      return 0;
    }
    if ( MyButton.id == 'Down' )
    {
      moverow('down');
      return 0;
    }
}

function SelectTab (MyTab)
{
  document.getElementById('general_div').style.display='none';
  document.getElementById('subtemplates_div').style.display='none';
  document.getElementById('advanced_div').style.display='none';
  document.getElementById('advanced2_div').style.display='none';
  document.getElementById('ovf_div').style.display='none';

  document.getElementById('general').style.background = "#05057A";
  document.getElementById('subtemplates').style.background = "#05057A";
  document.getElementById('advanced').style.background = "#05057A";
  if (document.getElementById('ovf'))
  {
    document.getElementById('ovf').style.background = "#05057A";
  }
  if(document.getElementById('advanced2'))
  {
    document.getElementById('advanced2').style.background = "#05057A";
  }

  document.getElementById(MyTab.id + '_div').style.display='block';
  document.getElementById(MyTab.id).style.background='#0505CA';
}  

