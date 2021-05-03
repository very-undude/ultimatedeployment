function PushButton (MyButton)
{
    if ( MyButton.id == 'Save' )
    {
      document.EDITSUBTEMPLATELISTFORM.button.value="save";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.EDITSUBTEMPLATELISTFORM.button.value="cancel";
    }
    document.EDITSUBTEMPLATELISTFORM.submit();
}

