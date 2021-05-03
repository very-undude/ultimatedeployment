function PushButton (Button)
{
  if ( Button.id == 'Shutdown' )
  {
    document.SHUTDOWNFORM.action.value='applyshutdown';
    document.SHUTDOWNFORM.submit();
  }
  if ( Button.id == 'Reboot' )
  {
    document.SHUTDOWNFORM.action.value='applyreboot';
    document.SHUTDOWNFORM.submit();
  }
  if ( Button.id == 'Cancel' )
  {
    location.href = '?module=system&action=status';
  }
}

