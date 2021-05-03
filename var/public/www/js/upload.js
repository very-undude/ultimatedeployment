var size = 0 ;
var total = 0 ;
var progress = 0;


function readableBytes(bytes) {
    if (bytes == 0)
    {
      return "0 bytes";
    }
    var i = Math.floor(Math.log(bytes) / Math.log(1024)),
    sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    return (bytes / Math.pow(1024, i)).toFixed(2) * 1 + ' ' + sizes[i];
}

function Update()
{
    result=window.frames[0].document.body.innerHTML ;
    if (result != '')
    {
      //alert(result);
      resultinfo=result.split(':');
      if (resultinfo[0] == 'SUCCESS')
      {
         document.getElementById('UPLOADRESULT').innerHTML = "<BR><FONT COLOR=GREEN><B>SUCCESS</B></FONT>" ;
         size=resultinfo[1];
         total=resultinfo[1];
      } else {
         document.getElementById('UPLOADRESULT').innerHTML = "<BR><FONT COLOR=RED><B>ERROR</B></FONT><BR>" + resultinfo[2] ;
         total=resultinfo[1];
      }
    }
    if (result == '')
    {
      document.getElementById('UPLOADRESULT').innerHTML = "<BR>Uploading.." ;
    }
    document.getElementById('size_div').innerHTML= total + " bytes (" +readableBytes(total) + ")" ;
    progress = Math.round(size / total * 100) ;
    if (progress > 100)
    {
      progress = 100;
    }
    document.getElementById('total_div').innerHTML= size + " bytes (" + readableBytes(size) + ")";
    if (progress > 7 )
    {
      document.getElementById("d5").innerHTML=parseInt(progress)+"%";
    }
    document.getElementById("d6").style.width=progress*3+"px";
}

function ClickUploadButton()
{
  // alert ("Button Pressed!");
  document.getElementById('upload_div').style.display = 'none';
  document.getElementById('progress_div').style.display = 'block';


  curfilename=document.forms[0].upload_file.value ;
  curfilename=curfilename.toLowerCase();
  if (curfilename.toLowerCase().indexOf('c:\\fakepath\\') == 0)
  {
     curfilename=curfilename.substr(12,curfilename.length+1)
  }
  //document.getElementById("filename_div").innerHTML = document.forms[0].upload_file.value ;
  document.getElementById("filename_div").innerHTML = curfilename ;
  document.getElementById('filename_div').style.display = 'block';

  document.getElementById('size_div').innerHTML = total + " bytes";
  document.getElementById('size_div').style.display = 'block';

  document.getElementById('total_div').innerHTML = size + " bytes (0%)";
  document.getElementById('total_div').style.display = 'block';

  document.getElementById("d5").innerHTML="";	
  document.getElementById("d6").style.width=0;  i=0;

  document.getElementById('UPLOADRESULT').innerHTML = "<BR>Initializing upload...";
  document.getElementById('UPLOADRESULT').style.display = 'block';

  t=setTimeout("loopMe()",3000)
  document.forms[0].submit();
}

//Browser Support Code
function ajaxFunction(){
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
                        var pos=answer.indexOf("/")
                        size = answer.substr(0,pos)
                        total = answer.substr(pos+1,answer.length+1)
			Update();
		}
	}
        var uploadid=document.forms[0].uploadid.value;
	ajaxRequest.open("GET", "/cgi-bin/upload_progress.cgi?uploadid="+uploadid, true);
	ajaxRequest.send(null); 
}

function loopMe()
{
  ajaxFunction();
  t=setTimeout("loopMe()",2000);
}

