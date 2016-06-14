ACCOUNT = ocramz
PROJECT = compute-cluster-sandbox
# TAG = $(ACCOUNT)/$(PROJECT)

.DEFAULT_GOAL := help

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo "  help     display this help message"
	@echo "  rbuild   build remotely (on Docker hub)"
	@echo "  pull     fetch precompiled image from Docker hub"
	@echo "  rebuild  '', ignoring previous builds"
	@echo "  run      run the image"


rbuild:
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-node/trigger/8b3df13c-d700-4669-8487-7e77302ac233/
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-master-node/trigger/72786211-6c20-4dce-9980-b6002d26025d/
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST https://registry.hub.docker.com/u/ocramz/compute-ca/trigger/f947b816-b839-4209-8881-50213091812b/
