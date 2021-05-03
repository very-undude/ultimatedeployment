function PushButton (Button)
{
  if ( Button.id == 'Apply' )
  {
    document.NEWMOUNTFORM.submit();
  }
  if ( Button.id == 'Cancel' )
  {
    location.href = '?module=mounts&action=list';
  }
}

