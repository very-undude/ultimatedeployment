//Browser Support Code
function Update(mymount,mypath){
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
                        document.getElementById('browse_div').innerHTML= answer;
		}
	}
	ajaxRequest.open("GET", "/cgi-bin/browse.cgi?mymount="+mymount+"&mypath="+mypath, true);
	ajaxRequest.send(null); 
}

function expand(path)
{
 curpath=document.getElementById('FILE1').value;

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
 document.getElementById('FILE1').value = curpath;
 mountname=document.getElementById('MOUNT').value;
 Update(mountname,curpath);
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

