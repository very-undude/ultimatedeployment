function PushButton (MyButton)
{
    if ( MyButton.id == 'Previous' )
    {
      document.WIZARDFORM.button.value="previous";
    }
    if ( MyButton.id == 'Next' )
    {
      if (!ValidateVarName(document.forms[0].OSFLAVOR.value,"Flavor Name"))
      {
        return false;
      }
      document.WIZARDFORM.button.value="next";
    }
    if ( MyButton.id == 'Finish' )
    {
      document.WIZARDFORM.button.value="finish";
    }
    if ( MyButton.id == 'Cancel' )
    {
      // document.WIZARDFORM.button.value="cancel";
      location.href= '?module=os&action=list';
    } else {
      document.WIZARDFORM.submit();
    }
}

