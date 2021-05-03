function PushButton (MyButton)
{
    if ( MyButton.id == 'Finish' )
    {
      document.WIZARDFORM.button.value="finish";
    }
    if ( MyButton.id == 'Next' )
    {
      if (!ValidateVarName(document.forms[0].TEMPLATENAME.value,"Template Name"))
      {
        return false;
      }
      document.WIZARDFORM.button.value="next";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.WIZARDFORM.button.value="cancel";
    }
    document.WIZARDFORM.submit();
}

