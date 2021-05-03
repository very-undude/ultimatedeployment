function moverow(x){
  if (!selectedRow)
  {
    return;
  }
  table=document.getElementById("templatesorttable");
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
}

