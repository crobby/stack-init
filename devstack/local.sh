source ~/src/devstack/openrc

# open up our vms...a little wide here, but I'm ok with that, you may not be

PRIVATE_NET_ID=$(neutron net-list | grep private | awk '{print $2}')
PUBLIC_NET_ID=$(neutron net-list | grep public | awk '{print $2}')

sudo iptables -t nat -A POSTROUTING -o enp0s25 -j MASQUERADE

# the following 2 lines are a bit experimental...
sudo iptables -A INPUT ACCEPT
sudo iptables -A FORWARD ACCEPT


neutron net-update $PRIVATE_NET_ID --shared True
neutron net-update $PUBLIC_NET_ID --shared True
neutron subnet-update private-subnet --dns_nameservers list=true 8.8.8.8 8.8.4.4

source ~/src/devstack/openrc demo demo

for group in $(neutron security-group-list | grep default | awk -F '|' '{ print $2 }')
do
    tenant_id=$(neutron security-group-show $group | grep tenant_id | awk '{print $4}' | tail -n 1)
        neutron security-group-rule-create --protocol icmp --direction ingress $group
        neutron security-group-rule-create --protocol icmp --direction egress $group
        neutron security-group-rule-create --protocol tcp --port-range-min 1 --port-range-max 65535 --direction ingress $group
        neutron security-group-rule-create --protocol tcp --port-range-min 1 --port-range-max 65535 --direction egress $group
        neutron security-group-rule-create --protocol udp --port-range-min 1 --port-range-max 65535 --direction egress $group
        neutron security-group-rule-create --protocol udp --port-range-min 1 --port-range-max 65535 --direction ingress $group
        break
done

source ~/src/devstack/openrc admin admin

for group in $(neutron security-group-list | grep default | awk -F '|' '{ print $2 }')
do
    tenant_id=$(neutron security-group-show $group | grep tenant_id | awk '{print $4}' | tail -n 1)
        neutron security-group-rule-create --protocol icmp --direction ingress $group
        neutron security-group-rule-create --protocol icmp --direction egress $group
        neutron security-group-rule-create --protocol tcp --port-range-min 1 --port-range-max 65535 --direction ingress $group
        neutron security-group-rule-create --protocol tcp --port-range-min 1 --port-range-max 65535 --direction egress $group
        neutron security-group-rule-create --protocol udp --port-range-min 1 --port-range-max 65535 --direction egress $group
        neutron security-group-rule-create --protocol udp --port-range-min 1 --port-range-max 65535 --direction ingress $group
        break
done



# I want an 11 gig flavor  <name, memory, cpus, storage, ephem, swap, ID>  change ID if you want multiple flavors
openstack flavor create c.fivegig --id 56 --ram 2048 --disk 5 --vcpus 1
openstack flavor create c.sixgig --id 55 --ram 2048 --disk 6 --vcpus 1
openstack flavor create c.eight --id 59 --ram 2048 --disk 8 --vcpus 1
openstack flavor create c.fourgig --id 53 --ram 2048 --disk 4 --vcpus 1
openstack flavor create c.threegig --id 54 --ram 2048 --disk 3 --vcpus 1
openstack flavor create c.cloudera --id 88 --ram 6144 --disk 9 --vcpus 1
openstack flavor create c.spark --id 99 --ram 2048 --disk 9 --vcpus 1

#nova flavor-create c1.elevengig 0 1024 11 1

#glance image-create --name=ubuntu-spark.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/ubuntu_sahara_spark_latest.qcow2
#glance image-create --name=new-fedora-oozie-hdp.image --disk-format=qcow2 --container-format=bare --is-public=True < ~/fedora_sahara_vanilla_hadoop_1_latest.qcow2

# This adds a keypair to nova
echo "Adding keypair to nova"
#openstack keypair create stackboxkp --public-key ~/.ssh/id_rsa.pub
nova keypair-add --pub_key ~/.ssh/id_rsa.pub stackboxkp

export MYHOST=localhost
keystone service-create --name sahara --type data-processing --description "Sahara Data Processing"
keystone endpoint-create --service sahara --region RegionOne --publicurl "http://$MYHOST:18080/v1.1/\$(tenant_id)s" --adminurl "http://$MYHOST:18080/v1.1/\$(tenant_id)s" --internalurl "http://$MYHOST:18080/v1.1/\$(tenant_id)s"

#create sahara-proxy domain
#python ~/devstack/domain.sh

source ~/src/devstack/openrc demo demo
#openstack keypair create stackboxkp --public-key ~/.ssh/id_rsa.pub
nova keypair-add --pub_key ~/.ssh/id_rsa.pub stackboxkp
