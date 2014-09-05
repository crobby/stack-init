from keystoneclient.v3 import Client
admin=Client(auth_url='http://localhost:5000/v3', username='admin', password='admin')
admin.domains.create('sahara_proxy')
