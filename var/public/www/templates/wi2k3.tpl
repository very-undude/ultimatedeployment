[RemoteInstall]
Repartition=Yes

[data]
floppyless = "1"
msdosinitiated = "1"
OriSrc = "\\[UDA_IPADDR]\REMINST\windows5\[FLAVOR]"
OriTyp = "4"
LocalSourceOnCD = 1
DisableAdminAccountOnDomainJoin = 1
UnattendedInstall = "Yes"

[SetupData]
OsLoadOptions = "/noguiboot /fastdetect"
SetupSourceDevice = "\Device\LanmanRedirector\[UDA_IPADDR]\REMINST\windows5\[FLAVOR]"

[UserData]
ComputerName=[TEMPLATE][SUBTEMPLATE]
FullName="Unattended install [FLAVOR]"
OrgName="Unknown Organisation"
;ProductID=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

[Unattended]
UnattendMode=FullUnattended 
OemSkipEula=Yes
TargetPath=\WINNT
Repartition=Yes
DriverSigningPolicy=Ignore
WaitForReboot=No

[GuiUnattended]
AdminPassword=WI2K3
OEMSkipRegional=1
TimeZone=110
OemSkipWelcome=1
AutoLogon=YES
AutoLogonCount=1
ServerWelcome=No

[Display]
BitsPerPel = "8"
XResolution = "800"
YResolution = "600"
VRefresh = "75"

[Networking]
InstallDefaultComponents=Yes

[LicenseFilePrintData]
AutoMode = "PerServer"
AutoUsers = "5"

