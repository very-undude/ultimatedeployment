<?xml version="1.0"?>
<!DOCTYPE profile SYSTEM
 "/usr/share/autoinstall/dtd/profile.dtd">
 <profile
 xmlns="http://www.suse.com/1.0/yast2ns"
 xmlns:config="http://www.suse.com/1.0/configns">
 <install>
    <general>
       <signature-handling>
         <accept_non_trusted_gpg_key config:type="boolean">true</accept_non_trusted_gpg_key>
         <accept_verification_failed config:type="boolean">true</accept_verification_failed>
      </signature-handling>
      <clock>
	<hwclock>UTC</hwclock>              
	<timezone>Europe/Amsterdam</timezone>	
      </clock>
      <keyboard>
	<keymap>us</keymap>              
      </keyboard>
      <language>en_US</language>
      <mode>                
	<confirm config:type="boolean">false</confirm>
	<forceboot config:type="boolean">true</forceboot>  
        <second_stage config:type="boolean">false</second_stage>
      </mode>
      <mouse>
	<device>/dev/psaux</device>     
	<id>ps0</id>	
      </mouse>
    </general>

    <report>    
      <messages>
	<show config:type="boolean">true</show>
	<timeout config:type="integer">10</timeout>
	<log config:type="boolean">true</log>
      </messages>
      <errors>
	<show config:type="boolean">true</show>
	<timeout config:type="integer">10</timeout>
	<log config:type="boolean">true</log>
      </errors>
      <warnings>
	<show config:type="boolean">true</show>
	<timeout config:type="integer">10</timeout>
	<log config:type="boolean">true</log>
      </warnings>
    </report>


    <bootloader>
      <loader_type>grub2</loader_type>
    </bootloader>


  <partitioning  config:type="list">
  <drive>
    <device>/dev/sda</device>            
    <use>all</use>
  </drive>
  </partitioning>


  <software>
    <products config:type="list">
      <product>SLES</product>
    </products>
    <base>Minimal</base>
  </software>

 </install>
 <configure>  

  <networking>
      <dns>
        <dhcp_hostname config:type="boolean">true</dhcp_hostname>
        <dhcp_resolv config:type="boolean">true</dhcp_resolv>
        <domain>local</domain>
        <hostname>linux</hostname>
      </dns>
      <interfaces config:type="list">
        <interface>
          <bootproto>dhcp</bootproto>
          <device>eth0</device>        
          <startmode>onboot</startmode>
        </interface>
      </interfaces>
    </networking>

  <users config:type="list">
      <user>
         <username>root</username>
         <user_password>test</user_password>
         <encrypted config:type="boolean">false</encrypted>
         <forename/>
         <surname/>
      </user>
   </users>

 </configure>
</profile>
