function PushButton (MyButton)
{

    if ( MyButton.id == 'Debug' )
    {
       setactivedrivers();
       setdriversort();
       debugdrivers();
       return 0;
    }
    if ( MyButton.id == 'Up' )
    {
      moverow('up');
      return 0;
    }
    if ( MyButton.id == 'Down' )
    {
      moverow('down');
      return 0;
    }

    if ( MyButton.id == 'Save' )
    {
      if (document.getElementById("winpedrvtable") != null)
      {
        setactivedrivers();
        setdriversort();
        // debugdrivers();
      }
      document.WIZARDFORM.button.value="save";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.WIZARDFORM.button.value="cancel";
    }
    document.WIZARDFORM.submit();
}
