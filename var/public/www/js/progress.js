var progress = 0;
var status = "Initialising...";
document.getElementById("progress_div").style.width=progress*3+"px";
document.getElementById('status_div').innerHTML= status ;

//Browser Support Code
function ajaxFunction(actionid){
       var myactionid=document.getElementById("actionid").value;
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
                        var progress = answer.substr(0,pos)
                        var status = answer.substr(pos+1,answer.length+1)
                        if ( progress < 0 )
                        {
                          document.getElementById("progress_div").style.width=100*3+"px";
                          document.getElementById('status_div').innerHTML='<FONT COLOR=RED><B>Error</B></FONT><BR><BR>' + status ;
                        } else {
                          if ( progress == 100)
                          {
                          document.getElementById("progress_div").style.width=100*3+"px";
                          document.getElementById('status_div').innerHTML='<FONT COLOR=GREEN><B>Success</B></FONT><BR><BR>' + status ;
                          } else {
                            document.getElementById("progress_div").style.width=progress*3+"px";
                            document.getElementById('status_div').innerHTML= status;
                          }
                        }
		}
	}
        // alert ("Hello " + myactionid);
	ajaxRequest.open("GET", "/cgi-bin/progress.cgi?actionid="+myactionid, true);
	ajaxRequest.send(null); 
}

function Update()
{
  var myactionid=document.getElementById("actionid").value;
  // alert("Hello " + myactionid);
  ajaxFunction();
  t=setTimeout("Update()",2000);
}

