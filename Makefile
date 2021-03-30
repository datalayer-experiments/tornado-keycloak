# Copyright (c) Datalayer https://datalayer.io
# Distributed under the terms of the Apache License, Version 2.0
# https://www.apache.org/licenses/LICENSE-2.0.txt

SHELL=/bin/bash

CONDA=source $$(conda info --base)/etc/profile.d/conda.sh
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
CONDA_DEACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda deactivate
CONDA_REMOVE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda remove -y --all -n

.PHONY: clean install

help: ## display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

default: help ## default target is help.

conda: ## create a conda environment
	($(CONDA); \
		conda deactivate && \
			conda remove -y --all -n tornado-oidc && \
		conda env create -f environment.yml )

clean:
	rm -fr .eggs
	rm -fr *.egg-info
	rm -fr dist

install:
	($(CONDA_ACTIVATE) tornado-oidc; \
		python setup.py install )

keycloak-rm: ## Remove any existing keycloak container.
	docker rm -f keycloak || true

keycloak-start: keycloak-rm
	docker run -it -d --rm \
	  -v ${PWD}/dev:/tmp/keycloak \
	  -e KEYCLOAK_USER=admin \
	  -e KEYCLOAK_PASSWORD=admin \
	  -p 8092:8080 \
	  --name keycloak \
	  jboss/keycloak:6.0.1
	make keycloak-logs

keycloak-logs:
	docker logs keycloak -f

keycloak-init:
	docker exec -it keycloak /tmp/keycloak/init-keycloak.sh

start:
	($(CONDA_ACTIVATE) tornado-oidc; \
		echo open http://localhost:8080 && \
		python main.py )
