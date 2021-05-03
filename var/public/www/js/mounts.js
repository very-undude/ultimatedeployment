function EnableDisableMountOptions (SelectBoxId)
{
  var SelectBox = document.getElementById(SelectBoxId);

  if (SelectBox.options[SelectBox.selectedIndex].value == "CIFS")
  {
    document.getElementById('CIFS_DIV').style.display = 'block';
  } 
  if (SelectBox.options[SelectBox.selectedIndex].value == "NFS")
  {
    document.getElementById('CIFS_DIV').style.display = 'none';
  } 
  if (SelectBox.options[SelectBox.selectedIndex].value == "LOCAL")
  {
    document.getElementById('CIFS_DIV').style.display = 'none';
  } 
}

