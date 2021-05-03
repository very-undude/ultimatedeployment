function PushButton (MyButton)
{
    if ( MyButton.id == 'Apply' )
    {
      document.WIZARDFORM.button.value="apply";
    }
    if ( MyButton.id == 'Cancel' )
    {
      document.WIZARDFORM.button.value="cancel";
    }
    document.WIZARDFORM.submit();
}

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
                        document.getElementById('EPWD').value = answer;
                }
        }
        var password=document.getElementById('PWD').value;
        ajaxRequest.open("GET", "/cgi-bin/sha1encode.cgi?password="+password, true);
        ajaxRequest.send(null);
}

function Encode()
{
  // alert(document.getElementById('PWD').value);
  ajaxFunction();
}
