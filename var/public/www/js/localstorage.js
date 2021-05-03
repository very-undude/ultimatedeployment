function PushButton (MyButton)
{
   if ( selectedRow)
   {
     var rowid = selectedRow.id;

     if ( MyButton.id == 'Extend' )
     {
       document.LOCALSTORAGE.button.value="extend";
       document.LOCALSTORAGE.volume.value=rowid;
       document.LOCALSTORAGE.submit();
     }
   }

   if ( MyButton.id == 'Cancel' )
   {
     document.LOCALSTORAGE.button.value="cancel";
     document.LOCALSTORAGE.submit();
   }
}

