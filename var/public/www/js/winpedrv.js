function PushButton (MyButton)
{
    if ( MyButton.id == 'Previous' )
    {
      document.WIZARDFORM.button.value="upload";
    }
    if ( MyButton.id == 'Cancel' )
    {
      location.href= '?module=system&action=status';
    } else {
      document.WIZARDFORM.submit();
    }
}

