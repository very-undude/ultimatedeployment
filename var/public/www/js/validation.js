function ValidateVarName (myval,fieldname)
{
  var value=myval;
  var myregexp=/^[a-zA-Z][a-zA-Z0-9_-]*$/;
  if (value==null||value==""||!myregexp.test(value))
  {
    alert("The " + fieldname + " field must contain a valid value. It must start with an alphabetic character followed by alphabetic charaters and/or numbers and or/the _ and/or the - character. It can not contain spacing, quotes or other special characters like %, *, #, . etc...");
    return false;
  } else {
    return true;
  }
}
