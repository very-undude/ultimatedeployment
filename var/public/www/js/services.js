function PushButton (Button)
{
  if ( selectedRow)
  {
    var rowid = selectedRow.id;
    var url =  '?module=services&service=' + rowid + '&action=';
    if ( Button.id == 'Stop' )
    {
      location.href= url + 'stop';
    }
    if ( Button.id == 'Start' )
    {
      location.href= url + 'start';
    }
    if ( Button.id == 'Restart' )
    {
      location.href= url + 'restart';
    }
    if ( Button.id == 'Configure' )
    {
      location.href= url + 'configure';
    }
    if ( Button.id == 'Logfile' )
    {
      location.href= url + 'logfile';
    }
  }
}

