function ReloadIndexedValues (SelectBoxId, ValueArray, Key)
{
  var SelectBox = document.getElementById(SelectBoxId);
  for (q=SelectBox.options.length;q>=0;q--)
  {
    SelectBox.options[q]=null ;
  }

  for (i=0; i<ValueArray.length; i++)
  {
    var pos=ValueArray[i].indexOf(";")
    var myclass = ValueArray[i].substr(0,pos)
    var mysubclass=ValueArray[i].substr(pos+1,ValueArray[i].length+1)
    if ( myclass == Key)
    {
       myEle = document.createElement("option") ;
       myEle.text = mysubclass ;
       SelectBox.options.add(new Option(mysubclass,mysubclass)) ;
    }
  }
}

function LoadValues (SelectBoxId, ValueArray)
{
  var SelectBox = document.getElementById(SelectBoxId);
  for (i=0; i<ValueArray.length; i++)
  {
    var pos=ValueArray[i].indexOf(";")
    var myid = ValueArray[i].substr(0,pos)
    var myname=ValueArray[i].substr(pos+1,ValueArray[i].length+1)
    SelectBox.options.add(new Option(myname,myid)) ;
  }
}

FileChange (DirectoryBoxId,FileBoxId)
{
   var Path=document.getElementByName("MOUNT");
   var Dir=document.getElementByName("DIR");
   var File=document.getElementById("FILE");
   
   var NewDirectoryArray;
   GetDirectoryList();
   

   GetFileList();
}
