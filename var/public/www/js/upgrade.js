function PushButton (MyButton)
{
    if ( MyButton.id == 'Apply' )
    {
      document.WIZARDFORM.button.value="apply";
      document.WIZARDFORM.submit();
    }
    if ( MyButton.id == 'Cancel' )
    {
      // document.WIZARDFORM.button.value="cancel";
     location.href = '?module=system&action=status';
    }
}

