function PushButton (MyButton)
{
    if ( MyButton.id == 'WinPE' )
    {
      document.SYSTEMFORM.action.value="winpe";
    }
    if ( MyButton.id == 'PXE' )
    {
      document.SYSTEMFORM.action.value="pxeconfig";
    }
    if ( MyButton.id == 'Upload' )
    {
      document.SYSTEMFORM.action.value="upload";
    }
    if ( MyButton.id == 'Network' )
    {
      document.SYSTEMFORM.action.value="network";
    }
    if ( MyButton.id == 'Password' )
    {
      document.SYSTEMFORM.action.value="password";
    }
    if ( MyButton.id == 'Shutdown' )
    {
      document.SYSTEMFORM.action.value="shutdown";
    }
    if ( MyButton.id == 'Upgrade' )
    {
      document.SYSTEMFORM.action.value="upgrade";
    }
    if ( MyButton.id == 'OvfTool' )
    {
      document.SYSTEMFORM.action.value="installovftool";
    }
    if ( MyButton.id == 'PowerShell' )
    {
      document.SYSTEMFORM.action.value="installpowershell";
    }
    if ( MyButton.id == 'VMTools' )
    {
      document.SYSTEMFORM.action.value="installvmwaretools";
    }
    if ( MyButton.id == 'Variables' )
    {
      document.SYSTEMFORM.action.value="systemvars";
    }
    if ( MyButton.id == 'Diskspace' )
    {
      document.SYSTEMFORM.action.value="localstorage";
    }
    if ( MyButton.id == 'Version' )
    {
      document.SYSTEMFORM.action.value="version";
    }
    if ( MyButton.id == 'Help' )
    {
      document.SYSTEMFORM.action.value="help";
    }
    if ( MyButton.id == 'Esx3NoSan' )
    {
      document.SYSTEMFORM.action.value="esx3nosan";
    }
    if ( MyButton.id == 'Esx4NoSan' )
    {
      document.SYSTEMFORM.action.value="esx4nosan";
    }
    if ( MyButton.id == 'Actions' )
    {
      document.SYSTEMFORM.action.value="actions";
    }

    document.SYSTEMFORM.submit();
}

