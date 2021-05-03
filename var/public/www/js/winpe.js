function PushButton (Button)
{
  var url =  '?module=system&action=';
  if ( Button.id == 'Add' )
  {
    location.href= url + 'addwinpedrv';
  }
  if ( selectedRow)
  {
    var rowid = selectedRow.id;
    if ( Button.id == 'Delete' )
    {
      location.href= url + 'delwinpedrv&driver=' + rowid;
    }
    if ( Button.id == 'Edit' )
    {
      location.href= url + 'editwinpedrv&driver=' + rowid;
    }
  }
}

