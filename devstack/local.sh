# get our env params
source ./devstack/openrc

# open up our vms...a little wide here, but I'm ok with that, you may not be
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0

# I want an 11 gig flavor  <name, memory, cpus, storage, ephem, swap, ID>  change ID if you want multiple flavors
nova-manage instance_type create c1.elevengig 1024 1 11 0 0 0

# I happen to have an image that I always want loaded
glance image-create --name=fedora-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/new-setenforce1-fedora_hadoop_1_1_2.qcow2

# I also open up the firewall on my local box that is running openstack (because I run dashboard/savanna from another box)
sudo firewall-cmd --add-port=1-65535/tcp || echo "already all set"

# This adds a keypair to nova, but doesn't quite seem to show up in the dashboard yet...may need tweaking
nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$OS_AUTH_URL keypair-add --pub_key ~/.ssh/id_rsa.pub stackboxkp 
