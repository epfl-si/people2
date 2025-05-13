APP_NAME=people
QUAY_REPO=quay-its.epfl.ch/svc0033/$(APP_NAME)
TAG=latest

# Chemin vers le Dockerfile
DOCKERFILE=../../../Dockerfile

# Build local
build: ../../../VERSION
	docker build -t $(APP_NAME):$(TAG) -f $(DOCKERFILE) ../../..

# Tag + push sur quay
push: build
	docker tag $(APP_NAME):$(TAG) $(QUAY_REPO):$(TAG)
	docker push $(QUAY_REPO):$(TAG)

# Nettoyage local
clean:
	docker rmi $(APP_NAME):$(TAG) || true
	docker rmi $(QUAY_REPO):$(TAG) || true

../../../VERSION:
	git tag -l --sort=creatordate | tail -n 1 | sed 's/\n//' > $@