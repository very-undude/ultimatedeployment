function PushButton (Button)
{
  if ( Button.id == 'New' )
  {
    location.href='?module=mounts&action=new';
  }
  if ( selectedRow)
  {
    var rowid = selectedRow.id;
    var url =  '?module=mounts&mount=' + rowid + '&action=';
    if ( Button.id == 'Delete' )
    {
      location.href= url + 'delete';
    }
    if ( Button.id == 'Mount' )
    {
      location.href= url + 'mount';
    }
    if ( Button.id == 'Unmount' )
    {
      location.href= url + 'unmount';
    }
    if ( Button.id == 'Configure' )
    {
      location.href= url + 'configure';
    }
  }
}

