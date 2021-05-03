var selectedRow = null ;

function SelectRow (obj)
{
    if ( selectedRow)
         selectedRow.style.backgroundColor= 'white';
    obj.style.backgroundColor= 'lightgrey';
    selectedRow = obj;
}

