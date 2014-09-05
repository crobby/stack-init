sudo setenforce 0

# get our env params
source ~/devstack/openrc

# open up our vms...a little wide here, but I'm ok with that, you may not be
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0

# I want an 11 gig flavor  <name, memory, cpus, storage, ephem, swap, ID>  change ID if you want multiple flavors
nova-manage flavor create c1.elevengig 1024 1 11 0 0 0

nova-manage flavor create --name c.test --memory 2048 --cpu 1 --root_gb 17 --ephemeral_gb 0 --flavor 15 --swap 0 --is_public True
nova-manage flavor create --name c.sixteengig --memory 2048 --cpu 1 --root_gb 17 --ephemeral_gb 0 --flavor 55 --swap 0 --is_public True
# I happen to have an image that I always want loaded
#glance image-create --name=fedora-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/new-setenforce1-fedora_hadoop_1_1_2.qcow2

#glance image-create --name=ubuntu-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/savanna-0.2-vanilla-1.1.2-oozie-3.3.2-ubuntu-13.10.qcow2
#glance image-create --name=ubuntu-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/savanna-0.3-vanilla-1.2.1-ubuntu-13.04.qcow2

glance image-create --name=ubuntu-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/ubuntu_sahara_vanilla_hadoop_1_latest.qcow2

#glance image-create --name=fedora-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/savanna-0.3-vanilla-1.2.1-fedora-19.qcow2

glance image-create --name=new-fedora-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/fedora_sahara_vanilla_hadoop_1_latest.qcow2

#glance image-create --name=fedora-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/savanna-icehouse-vanilla-1.2.1-fedora-19.qcow2

#glance image-create --name=rhel-server.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/rhel-server-x86_64-kvm-6.4_20130130.0-4.qcow2

# I also open up the firewall on my local box that is running openstack (because I run dashboard/savanna from another box)
sudo firewall-cmd --add-port=1-65535/tcp || echo "already all set"

# This adds a keypair to nova
echo "Adding keypair to nova"
nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$OS_AUTH_URL keypair-add --pub_key ~/.ssh/id_rsa.pub stackboxkp

export OS_USERNAME=admin
keystone service-create --name sahara --type data_processing --description "Sahara Data Processing"
keystone endpoint-create --service sahara --region RegionOne --publicurl "http://127.0.0.1:18080/v1.1/\$(tenant_id)s" --adminurl "http://127.0.0.1:18080/v1.1/\$(tenant_id)s" --internalurl "http://127.0.0.1:18080/v1.1/\$(tenant_id)s"

#create sahara-proxy domain
~/devstack/domain.sh
