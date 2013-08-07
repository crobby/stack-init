cd ~/src/savanna
export TOKEN=$(tools/get_auth_token | grep "Auth token:" | awk '{print $3}')
export TENANT=$(tools/get_auth_token | grep "Tenant \[admin\]" | awk '{print $4}')

http http://localhost:18080/v1.0/$TENANT/node-group-templates X-Auth-Token:$TOKEN < ~/src/master.ngt
http http://localhost:18080/v1.0/$TENANT/node-group-templates X-Auth-Token:$TOKEN < ~/src/worker.ngt

#a little json query tool
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x jq

export MASTER_ID=$(http http://localhost:18080/v1.0/$TENANT/node-group-templates X-Auth-Token:$TOKEN | ./jq ".node_group_templates[0].id")
export WORKER_ID=$(http http://localhost:18080/v1.0/$TENANT/node-group-templates X-Auth-Token:$TOKEN | ./jq ".node_group_templates[1].id")

rm jq

cp ~/src/cluster.tmp ~/src/cluster.tmp.bak

sed -i "s/MASTER_ID/$MASTER_ID/g" ~/src/cluster.tmp
sed -i "s/WORKER_ID/$WORKER_ID/g" ~/src/cluster.tmp

http http://localhost:18080/v1.0/$TENANT/cluster-templates X-Auth-Token:$TOKEN < ~/src/cluster.tmp

cp ~/src/cluster.tmp.bak ~/src/cluster.tmp
rm ~/src/cluster.tmp.bak

#register our image
#get the image id for our known image
export AUTH_URL="http://192.168.1.44:5000/v2.0"

export IMAGE_ID=$(nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$AUTH_URL image-list | grep fedora-hdp.image | awk {'print $2'})
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID X-Auth-Token:$TOKEN < ~/src/image.reg
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID/tag X-Auth-Token:$TOKEN < ~/src/tags.reg

