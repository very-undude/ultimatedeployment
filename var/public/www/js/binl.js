function PushButton (MyButton)
{
    if ( MyButton.id == 'Save' )
    {
      document.BINLFORM.button.value="add";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.BINLFORM.button.value="cancel";
    }
    if ( MyButton.id == 'Logfile' )
    {
      document.BINLFORM.button.value="logfile";
    }
    if ( MyButton.id == 'Database' )
    {
      document.BINLFORM.button.value="database";
    }
    document.BINLFORM.submit();
}

