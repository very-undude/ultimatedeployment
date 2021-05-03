function PushButton (MyButton)
{
  if ( MyButton.id == 'New' )
  {
      document.WIZARDFORM.action.value="new";
      document.WIZARDFORM.submit();
  }
 
  
  if ( selectedRow)
  {
    var rowid = selectedRow.id;
    document.WIZARDFORM.flavor.value=rowid;
    document.WIZARDFORM.os.value=selectedRow.cells[1].innerHTML;
    if ( MyButton.id == 'Delete' )
    {
      document.WIZARDFORM.action.value="delete";
    }
    if ( MyButton.id == 'Mount' )
    {
      document.WIZARDFORM.action.value="mount";
    }
    if ( MyButton.id == 'Unmount' )
    {
      document.WIZARDFORM.action.value="unmount";
    }
    if ( MyButton.id == 'Drivers' )
    {
      document.WIZARDFORM.action.value="drivers";
      document.WIZARDFORM.button.value="edit";
    }
    document.WIZARDFORM.submit();
  }

}

