function PushButton (Button)
{
  if ( Button.id == 'Apply' )
  {
    document.EDITVARSFORM.button.value='apply';
  }
  if ( Button.id == 'Cancel' )
  {
    document.EDITVARSFORM.button.value='cancel';
  }
  document.EDITVARSFORM.submit();
}

