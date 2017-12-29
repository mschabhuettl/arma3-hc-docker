NAME := arma3-headless-client
REPO := us.gcr.io/pdg-hosting
TAG := latest

build:
	docker build -t $(NAME) .
	docker tag $(NAME) $(REPO)/$(NAME):$(TAG)
.PHONY: build

push: build
	gcloud docker -- push $(REPO)/$(NAME):$(TAG)
.PHONY: push

default: build
.PHONY: default
