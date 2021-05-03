function PushButton (MyButton)
{
    if ( MyButton.id == 'Save' )
    {
      if (!ValidateVarName(document.forms[0].NEWTEMPLATENAME.value,"Template Name"))
      {
        return false;
      }
      document.WIZARDFORM.button.value="save";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.WIZARDFORM.button.value="cancel";
    }
    document.WIZARDFORM.submit();
}

