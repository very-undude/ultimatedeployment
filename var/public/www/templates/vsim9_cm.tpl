ngsh -c security login password -username admin -new-password \"netapp123\"
ngsh -c security login create -username admin -application ssh -authmethod password
ngsh -c timezone -timezone Europe/Amsterdam
ngsh -c system node rename -newname node1
ngsh -c system node run -node node1 -command 'disk assign all'
ngsh -c system node modify -node node1 -location MyLocation
ngsh -c network port modify -node node1 -port e0a -ipspace Cluster
ngsh -c network port modify -node node1 -port e0b -ipspace Cluster
ngsh -c network port modify -node node1 -port e0c -ipspace Default
ngsh -c network port modify -node node1 -port e0d -ipspace Default

# Create cluster interfaces
ngsh -c network interface create -lif clus1 -role cluster -home-node node1 -home-port e0a -status-admin up -address 169.254.0.1 -netmask 255.255.255.0 -vserver Cluster
ngsh -c network interface create -lif clus2 -role cluster -home-node node1 -home-port e0b -status-admin up -address 169.254.0.2 -netmask 255.255.255.0 -vserver Cluster
# Create node management interface
ngsh -c network interface create -lif node1_mgmt -role node-mgmt -home-node node1 -home-port e0c -status-admin up -address 192.168.145.101 -netmask 255.255.255.0

######### Cluster join
#ngsh -c cluster join -clusteripaddr 169.254.0.1
#sleep 30

######## Cluster create
ngsh -c cluster create -clustername cluster01 -license [NETAPP_VSIM_LICENSE]
sleep 30
ngsh -c network interface create -lif cluster_mgmt -role cluster-mgmt -home-node node1 -home-port e0d -status-admin up -address 192.168.145.100 -netmask 255.255.255.0
ngsh -c network route create -gateway 192.168.145.1 -vserver cluster01 -metric 10
ngsh -c aggr create -aggregate aggr1 -diskcount 5
