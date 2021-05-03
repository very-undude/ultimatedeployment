function PushButton (MyButton)
{
  if ( MyButton.id == 'Save' )
  {
      document.SERVICEFORM.button.value="save";
      document.SERVICEFORM.submit();
  }
  if ( MyButton.id == 'Cancel' )
  {
      document.SERVICEFORM.button.value="cancel";
      document.SERVICEFORM.submit();
  }
  if ( selectedRow)
  {
      document.SERVICEFORM.flavor.value=selectedRow.id;
      if ( MyButton.id == 'Database' )
      {
        document.SERVICEFORM.button.value="database";
      }
      if ( MyButton.id == 'Add' )
      {
        document.SERVICEFORM.button.value="adddriver";
      }

      document.SERVICEFORM.submit();
  }

}

