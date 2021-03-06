ACCOUNT = ocramz
PROJECT = compute-cluster-sandbox
# TAG = $(ACCOUNT)/$(PROJECT)

.DEFAULT_GOAL := help

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo "  help     display this help message"
	@echo "  rbuild   build remotely (on Docker hub)"
	@echo "  test_all gen TLS certs and test compose cluster"

export NNODES=4


rbuild:
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-node/trigger/8b3df13c-d700-4669-8487-7e77302ac233/
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-master-node/trigger/72786211-6c20-4dce-9980-b6002d26025d/
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-ca/trigger/f947b816-b839-4209-8881-50213091812b/


ca_run0:
	docker run --rm -it ocramz/compute-ca /bin/bash

master_run0:
	docker run --rm -it ocramz/compute-master-node /bin/bash

node_run0:
	docker run --rm -it ocramz/compute-node /bin/bash


test_all:
	# make ca_create_certs
	make cluster_provision
	# make ca_copy_certs
	make cluster_shutdown

ca_create_certs:
	mkdir -p ${PWD}/tls_certs
	ls -lsA
	docker run --rm -i -v ${PWD}/tls_certs:/.tls/certs ocramz/compute-ca /bin/bash ./generate-certs.sh ${NNODES}
	ls -lsA tls_certs

ca_copy_certs:
	for ii in `seq 1 $$NNODES`; do \
	    docker cp ${PWD}/tls_certs/node$$ii-cert.pem computeclustersandbox_node_$$ii:/home/mpirun/.ssh/ ; \
	done


cluster_provision:
	docker-compose scale master=1 node="${NNODES}"

cluster_shutdown:
	docker-compose down










# docker-machine-create:
# 	docker-machine create -d virtualbox node0

# # create and start
# compose-up:
# 	docker-compose up -d

# # stop and remove *everything* (containers, netw, images, volumes)
# compose-dn:
# 	docker-compose down

# # # ==== docker-compose and docker swarm integration:
# # $ eval "$(docker-machine env --swarm <name of swarm master machine>)"
# # $ docker-compose up





# # # test overlay network:
# # # # https://docs.docker.com/engine/userguide/networking/get-started-overlay/

# test_overlay_on:
# 	# create a VM for Consul key-value store (host) and set up to work with its env.variables
# 	docker-machine create -d virtualbox consul-kvs
# 	eval "$(docker-machine env consul-kvs)"
# 	docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap
# 	# create docker swarm master VM
# 	docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://$(docker-machine ip consul-kvs):8500" --engine-opt="cluster-store=consul://$(docker-machine ip consul-kvs):8500" --engine-opt="cluster-advertise=eth1:2376" node-master
# 	# create a node, add it to cluster
# 	docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$(docker-machine ip consul-kvs):8500" --engine-opt="cluster-store=consul://$(docker-machine ip consul-kvs):8500" --engine-opt="cluster-advertise=eth1:2376" node-slave1
# 	# switch to work on Swarm master
# 	eval $(docker-machine env --swarm node-master)
# 	# visualize swarm info
# 	docker info
# 	# create overlay network
# 	# only need to create the network on a single host in the cluster. In this case, you used the Swarm master but you could easily have run it on any host in the cluster.
# 	docker network create --driver overlay --subnet=10.0.9.0/24 my-net

# test_overlay_off:
# 	docker-machine rm -y consul-kvs node-master node-slave1
# 	docker-machine ls
# 	docker network ls

# test_overlay: test_overlay_on test_overlay_off
