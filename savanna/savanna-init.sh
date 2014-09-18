cd ~/src/sahara
source ~/src/sahara/.tox/venv/bin/activate

## needed to run sahara cli
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
## end of sahara cli stuff

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
export AUTH_URL="http://127.0.0.1:5000/v2.0"

#echo "Setting up ubuntu oozie image"
export IMAGE_ID=$(nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$AUTH_URL image-list | grep ubuntu-oozie-hdp.image | awk {'print $2'})
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID X-Auth-Token:$TOKEN < ~/src/ubu-image.reg
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID/tag X-Auth-Token:$TOKEN < ~/src/tags.reg

export IMAGE_ID=$(nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$AUTH_URL image-list | grep fedora | awk {'print $2'})
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID X-Auth-Token:$TOKEN < ~/src/fedora-image.reg
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID/tag X-Auth-Token:$TOKEN < ~/src/tags.reg

export IMAGE_ID=$(nova --os-username=admin --os-tenant-name=admin --os-password=admin --os-auth-url=$AUTH_URL image-list | grep icehouse | awk {'print $2'})
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID X-Auth-Token:$TOKEN < ~/src/fedora-image.reg
http http://localhost:18080/v1.0/$TENANT/images/$IMAGE_ID/tag X-Auth-Token:$TOKEN < ~/src/tags.reg

#sample data sources
echo "Setting up sample data sources"
http http://localhost:18080/v1.1/$TENANT/data-sources X-Auth-Token:$TOKEN < ~/src/output.tmp
http http://localhost:18080/v1.1/$TENANT/data-sources X-Auth-Token:$TOKEN < ~/src/output2.tmp
http http://localhost:18080/v1.1/$TENANT/data-sources X-Auth-Token:$TOKEN < ~/src/input.tmp

#sample pig job binary
#http PUT http://localhost:18080/v1.1/$TENANT/job-binary-internals/script.pig X-Auth-Token:$TOKEN < ../jobbinary.txt

#http http://localhost:18080/v1.1/$TENANT/jobs X-Auth-Token:$TOKEN < ../job.tmp
