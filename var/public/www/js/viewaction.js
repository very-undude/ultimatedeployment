function PushButton (MyButton)
{
  if ( MyButton.id == 'Back' )
  {
     document.ACTIONFORM.button.value="back";
  }
  if ( MyButton.id == 'Delete' )
  {
     document.ACTIONFORM.button.value="delete";
  }
  if ( MyButton.id == 'Kill' )
  {
     document.ACTIONFORM.button.value="kill";
  }
  document.ACTIONFORM.submit();
}

