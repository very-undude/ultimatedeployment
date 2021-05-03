function Reload()
{
  for (q=document.forms[0].FILE1.options.length;q>=0;q--)
  {
   document.forms[0].FILE1.options[q]=null ;
  }
  var curshare =  document.forms[0].MOUNT.options[document.forms[0].MOUNT.selectedIndex].value ;
  for (i=0; i<allisos.length; i++)
  {
    var pos=allisos[i].indexOf(";")
    var myclass = allisos[i].substr(0,pos)
    var mysubclass=allisos[i].substr(pos+1,allisos[i].length+1)
    if ( myclass == curshare)
    {
       myEle = document.createElement("option") ;
       myEle.text = mysubclass ;
       document.forms[0].FILE1.options.add(new Option(mysubclass,mysubclass)) ;
    }
  }
}
