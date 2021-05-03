function PushButton (MyButton)
{
    if ( MyButton.id == 'New' )
    {
      document.TEMPLATELISTFORM.action.value="new";
      document.TEMPLATELISTFORM.submit();
    }

    if ( MyButton.id == 'Sort' )
    {
      document.TEMPLATELISTFORM.action.value="sort";
      document.TEMPLATELISTFORM.submit();
    }


    if ( selectedRow)
    {
      document.TEMPLATELISTFORM.template.value=selectedRow.id;
      if ( MyButton.id == 'Deploy' )
      {
        document.TEMPLATELISTFORM.action.value="deploy";
      }
      if ( MyButton.id == 'Delete' )
      {
        document.TEMPLATELISTFORM.action.value="delete";
      }
      if ( MyButton.id == 'Copy' )
      {
        document.TEMPLATELISTFORM.action.value="copy";
      }
      if ( MyButton.id == 'Configure' )
      {
        document.TEMPLATELISTFORM.action.value="configure";
      }
      document.TEMPLATELISTFORM.submit();
    }
}

