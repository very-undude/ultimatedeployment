function selectactivedrivers()
{
  activedrivers=document.getElementById("activedrivers").value;
  if (activedrivers == "")
  {
    return 0;
  }
  activedriverarray=activedrivers.split(";");
  for (i=0;i<activedriverarray.length;i++)
  {
    if (document.getElementById(activedriverarray[i]) != null)
    {
      document.getElementById(activedriverarray[i]).checked = 1;
    }
  }
  
  return 0;
}

function setactivedrivers()
{
   sorteddrivers=document.getElementById("sorteddrivers").value;
   activearray=new Array;
   var index=0
   driverarray=sorteddrivers.split(";");
   for (i=0;i<driverarray.length;i++)
   {
     // alert(driverarray[i]);
     if (document.getElementById(driverarray[i]) != null)
     {
       if (document.getElementById(driverarray[i]).checked == 1)
       {
         // alert("Driver " + driverarray[i] + " is CHECKED");
         activearray[index++]=driverarray[i];
       }
     }
   }
   document.getElementById("activedrivers").value=activearray.join(";");
   // alert("Active = " + document.getElementById("activedrivers").value);
}


function debugdrivers()
{
   alert("Active = " + document.getElementById("activedrivers").value);
   alert("Sorted = " + document.getElementById("sorteddrivers").value);
  
}

function setdriversort()
{

      table=document.getElementById("winpedrvtable");
      sorteddriverarray=new Array;
      var index=0;
      for (i=1;i<=table.rows.length-1;i++)
      {
        sorteddriverarray[index++]="WINPEDRV_" + table.rows[i].cells[1].innerHTML;
        // alert("adding driver " + table.rows[i].cells[1].innerHTML);
      }
      document.getElementById("sorteddrivers").value=sorteddriverarray.join(";");

}

function moverow(x){
  if (!selectedRow)
  {
    return;
  }
  setactivedrivers();

  table=document.getElementById("winpedrvtable");
  whichrow=selectedRow;
  index=whichrow.rowIndex;
  htmlcode = table.rows[index].innerHTML;
  newindex=-1;
  if (x=='up'&&index > 1)
  {
    newindex=index-1;
  }
  else if (x=='down'&&index!=table.rows.length-1)
  {
    newindex=index+1;
  }
  else if (x=='first')
  {
    newindex=1;
  }
  else if (x=='last')
  {
    newindex=table.rows.length-1;
  }
  if (newindex !=-1)
  {
   var rowarray= new Array ()
   for (i=0;i<table.rows[index].cells.length;i++)
   {
     rowarray[i]=table.rows[index].cells[i].innerHTML;
   }
    table.deleteRow(index);
    table.insertRow(newindex);
    for (i=0;i<table.rows[index].cells.length;i++)
    {
      td=document.createElement("TD");
      td.innerHTML=rowarray[i];
      table.rows[newindex].appendChild(td);
    }
    table.rows[newindex].onclick=function(){
                                SelectRow(this);
                              }
    SelectRow(table.rows[newindex]);
  }
  selectactivedrivers();
}

