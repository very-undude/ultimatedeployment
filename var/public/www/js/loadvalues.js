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

function LoadReferencedValues (SelectBoxId, ValueArray, ReferenceArray)
{
  var SelectBox = document.getElementById(SelectBoxId);
  for (i=0; i<ValueArray.length; i++)
  {
    var pos=ValueArray[i].indexOf(";")
    var myid=ValueArray[i].substr(0,pos)
    var myname=ValueArray[i].substr(pos+1,ValueArray[i].length+1)
    var foundflavor=0
    for(j=0;j<ReferenceArray.length;j++)
    {
      var refpos=ReferenceArray[j].indexOf(";")
      var refid=ReferenceArray[j].substr(0,refpos)
      if (refid == myid)
      {
        foundflavor=1
      }
    }
    if(foundflavor==1)
    {
      SelectBox.options.add(new Option(myname,myid)) ;
    }
  }
}

function PreSelect (SelectBoxId, SelectValue)
{
  var SelectBox = document.getElementById(SelectBoxId);
  for (index=0;index<SelectBox.length;index++)
  {
    if (SelectBox[index].value == SelectValue)
    {
      SelectBox.selectedIndex=index;
    }
  }
}

