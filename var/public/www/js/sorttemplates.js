function PushButton (MyButton)
{
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
      table=document.getElementById("templatesorttable");
      templatestring="";
      for (i=1;i<=table.rows.length-1;i++)
      {
        templatestring += table.rows[i].cells[0].innerHTML + ";" ;
      }
      document.forms[0].elements['action'].value="sort";
      document.forms[0].elements['button'].value="save";
      document.forms[0].elements['SORT'].value=templatestring;
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.forms[0].elements['button'].value="cancel";
    }
    document.forms[0].submit();
}

