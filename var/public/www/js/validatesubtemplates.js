function ValidateSubtemplates (obj)
{
    var lines=obj.value;
    lines.replace(/(\x0a\x0d|\x0d\x0a)/g,"\n");
    var linearray=lines.split("\n");
    var headerarray=new Array;
    var headercount=0;
    var subtemplateindex=-1;
    var linecount=0;
    var subtemplatelist=new Array;
    for (var i=0;i<linearray.length;i++)
    {
      if (/^\s*$/.test(linearray[i]))
      {
        // alert('Empty Line found');
      } else {
        linecount++;
        linearray[i]=linearray[i].replace(/\s+$/g,"");
        if (linecount==1)
        {
          headerarray=linearray[i].split(";");
          headercount=headerarray.length;
          for (var j=0;j<headerarray.length;j++)
          {
            if (/^[A-Za-z][A-Za-z0-9_]*$/.test(headerarray[j]))
            {
              // alert('Valid fieldname found: "' + headerarray[j] + '"');
            } else {
              alert('Invalid fieldname found: "' + headerarray[j] + '"');
              return false;
            }
            if(headerarray[j] == 'SUBTEMPLATE')
            {
              subtemplateindex=j;
            }
          }
          if (subtemplateindex <0)
          {
            alert('No SUBTEMPLATE field found in the header row: "' + linearray[i] +'"');
            return false;
          }
          if (subtemplateindex>0)
          {
            alert('SUBTEMPLATE field should be the first in the header row: "' + linearray[i] +'"');
            return false;
          }
        } else {
          var datalinearray=linearray[i].split(";");
          if (datalinearray.length != headercount)
          {
             alert('Number of data fields unequal to the number of header fields for line "' + linearray[i] + '"' );
             return false;
          }
          subtemplatename=datalinearray[subtemplateindex];
          if (/^[A-Za-z][A-Za-z0-9_-]*$/.test(subtemplatename))
          { 
            // alert ('Valid subtemplatename found: "' + datalinearray[subtemplateindex] + '"');
          } else {
            alert('No valid subtemplate name "' + datalinearray[subtemplateindex] + '" on line "' + linearray[i] + '"');
            return false;
          }
          if (subtemplatelist[subtemplatename]==1)
          {
            alert('Invalid subtemplate name (not unique) on line "' + linearray[i] + '"');
            return false;
          }
          subtemplatelist[subtemplatename]=1;
        }
      }
    }
    return true;
}
