function PushButton (MyButton)
{
    if ( MyButton.id == 'Apply' )
    {
      document.DRIVERFORM.submit();
    }
    if ( MyButton.id == 'Cancel' )
    {
      location.href='uda3.pl?module=services&action=configure&service=binl';
    }
}
