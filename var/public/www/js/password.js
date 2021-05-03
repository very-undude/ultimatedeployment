function PushButton (Button)
{
  if ( Button.id == 'Apply' )
  {
    if ( document.PASSWORDFORM.NEWPASSWORD1.value == document.PASSWORDFORM.NEWPASSWORD2.value )
    {
      document.PASSWORDFORM.submit();
    } else {
      alert ('The new password does not match the password confirmation, try again');
    }
  }
  if ( Button.id == 'Cancel' )
  {
    location.href = '?module=system&action=status';
  }
}

