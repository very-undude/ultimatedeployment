function PushButton (MyButton)
{
  if ( MyButton.id == 'Save' )
  {
      document.SERVICEFORM.button.value="save";
  }
  if ( MyButton.id == 'Cancel' )
  {
      document.SERVICEFORM.button.value="cancel";
  }
  if ( MyButton.id == 'Database' )
  {
      document.SERVICEFORM.button.value="database";
  }
  document.SERVICEFORM.submit();
}

