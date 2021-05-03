function UpdateFiles(mymount,mypath){
        var ajaxRequest;  // The variable that makes Ajax possible!

        try{
                // Opera 8.0+, Firefox, Safari
                ajaxRequest = new XMLHttpRequest();
        } catch (e){
                // Internet Explorer Browsers
                try{
                        ajaxRequest = new ActiveXObject("Msxml2.XMLHTTP");
                } catch (e) {
                        try{
                                ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
                        } catch (e){
                                // Something went wrong
                                alert("Your browser broke!");
                                return false;
                        }
                }
        }
        // Create a function that will receive data sent from the server
        ajaxRequest.onreadystatechange = function(){
                if(ajaxRequest.readyState == 4){
                        var answer = ajaxRequest.responseText;
                        // document.getElementById('browse_div').innerHTML= answer;
                        var lines=answer
                        // alert(answer);
                        lines.replace(/(\x0a\x0d|\x0d\x0a)/g,"\n");
                        // alert(lines);
                        var linearray=lines.split("\n");
                        for (var i=0;i<linearray.length;i++)
                        {
                          if (/^\s*$/.test(linearray[i]))
                          {
                            // alert('Empty Line found');
                          } else {
                            // alert(linearray[i]);
                            myEle = document.createElement("option") ;
                            myEle.text = linearray[i] ;
                            var SelectBox1=document.getElementById('FILE1');
                            SelectBox1.options.add(new Option(linearray[i],linearray[i])) ;
                            var SelectBox2=document.getElementById('FILE2');
                            SelectBox2.options.add(new Option(linearray[i],linearray[i])) ;
                            var SelectBox3=document.getElementById('FILE3');
                            SelectBox3.options.add(new Option(linearray[i],linearray[i])) ;
                            var SelectBox4=document.getElementById('FILE4');
                            SelectBox4.options.add(new Option(linearray[i],linearray[i])) ;
                          }
                        }
                }
        }
        ajaxRequest.open("GET", "/cgi-bin/browse_files.cgi?mymount="+mymount+"&mypath="+mypath, true);
        ajaxRequest.send(null);
}

function UpdateDirs(mymount,mypath){
	var ajaxRequest;  // The variable that makes Ajax possible!
	
	try{
		// Opera 8.0+, Firefox, Safari
		ajaxRequest = new XMLHttpRequest();
	} catch (e){
		// Internet Explorer Browsers
		try{
			ajaxRequest = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try{
				ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e){
				// Something went wrong
				alert("Your browser broke!");
				return false;
			}
		}
	}
	// Create a function that will receive data sent from the server
	ajaxRequest.onreadystatechange = function(){
		if(ajaxRequest.readyState == 4){
			var answer = ajaxRequest.responseText;
                        // document.getElementById('browse_div').innerHTML= answer;
                        var lines=answer
                        lines.replace(/(\x0a\x0d|\x0d\x0a)/g,"\n");
                        var linearray=lines.split("\n");
                        for (var i=0;i<linearray.length;i++)
                        {
                          if (/^\s*$/.test(linearray[i]))
                          {
                            // alert('Empty Line found');
                          } else {
                            myEle = document.createElement("option") ;
                            myEle.text = linearray[i] ;
                            var SelectBox1=document.getElementById('DIRECTORY');
                            SelectBox1.options.add(new Option(linearray[i],linearray[i])) ;
                          }
                        }

		}
	}
	ajaxRequest.open("GET", "/cgi-bin/browse_dirs2.cgi?mymount="+mymount+"&mypath="+mypath, true);
	ajaxRequest.send(null); 
}

function expand(path)
{
 if ( path != "-- Change Directory --")
 {
 curpath=document.getElementById('PATH').value;
 if ( path == ".." )
 {
   curpath = curpath.substr(0,curpath.lastIndexOf("/"));
   if ( curpath == "" )
   {
     curpath = "/";
   }
 } else {
   if ( path == "/" )
   {
    curpath = path;
   } else {
   if ( curpath == "/" )
   {
    curpath += path ;
   } else {
    curpath += "/" + path;
   }
  }
 }
 document.getElementById('PATH').value = curpath;
 mountname=document.getElementById('MOUNT').value;
 ClearFileSelects();
 UpdateFiles(mountname,curpath);
 UpdateDirs(mountname,curpath);
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

