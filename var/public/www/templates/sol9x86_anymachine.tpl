install_type    initial_install
system_type     server
#system_type    standalone
# Partitioning types:
#              default -  JumpStart Selects and Creates FileSystems
#              existing - Keep the current
#              explicit - specified using the file systems keywork 

#               
#               
#               
#               
#               
partitioning    default
#partitioning    explicit
# cluster types: 
#               SUNWCrnet - Reduced Network Support Software Group
#               SUNWCreq  - Core System Support Software Group
#               SUNWCuser - End User Solaris Software Group
#               SUNWCprog - Developer Solaris software Group
#               SUNWCall  - Entire Solaris Software Group
#               SUNWCXall - Entire Solaris Software Group + OEM Support
# cluster         SUNWCuser
#cluster         SUNWCXuser
cluster         SUNWCreq

#filesys c1t0d0s7 24 
#filesys c1t1d0s7 24 
#metadb c1t0d0s7 count 3
#metadb c1t1d0s7 count 3
#filesys mirror:d30 c1t0d0s3 c1t1d0s3 10000 /var 
#filesys mirror:d10 c1t0d0s1 c1t1d0s1 2000 swap 
#filesys mirror:d0  c1t0d0s0 c1t1d0s0 free / 
