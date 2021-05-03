function PushButton (MyButton)
{
  if ( selectedRow)
  {
     var rowid = selectedRow.id;
     if ( MyButton.id == 'View' )
     {
       document.ACTIONFORM.button.value="view";
       document.ACTIONFORM.actionid.value=rowid;
       document.ACTIONFORM.submit();
    }
    if ( MyButton.id == 'Delete' )
    {
       document.ACTIONFORM.button.value="delete";
       document.ACTIONFORM.actionid.value=rowid;
       document.ACTIONFORM.submit();
    }
  }
  if ( MyButton.id == 'Cleanup' )
  {
     document.ACTIONFORM.button.value="cleanup";
     document.ACTIONFORM.actionid.value=rowid;
  }
  document.ACTIONFORM.submit();
}

