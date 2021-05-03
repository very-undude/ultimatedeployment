function PushButton (MyButton)
{
   if ( selectedRow)
   {
     var rowid = selectedRow.id;

     if ( MyButton.id == 'Apply' )
     {
       document.LOCALSTORAGE.button.value="add";
       document.LOCALSTORAGE.device.value=rowid;
       document.LOCALSTORAGE.submit();
     }
   }

   if ( MyButton.id == 'Cancel' )
   {
     document.LOCALSTORAGE.button.value="cancel";
     document.LOCALSTORAGE.submit();
   }
}

