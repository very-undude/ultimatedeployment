function PushButton (Button)
{
  if ( Button.id == 'Apply' )
  {
    document.NETWORKFORM.submit();
  }
  if ( Button.id == 'Cancel' )
  {
    location.href = '?module=system&action=status';
  }
}

