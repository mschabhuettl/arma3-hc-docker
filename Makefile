NAME := arma3-headless-client
REPO := us.gcr.io/pdg-hosting
TAG := latest

.PHONY: build push default clean

build:
	@echo "Building Docker image: $(NAME)"
	docker build -t $(NAME) .
	@echo "Tagging image as $(REPO)/$(NAME):$(TAG)"
	docker tag $(NAME) $(REPO)/$(NAME):$(TAG)

push: build
	@echo "Pushing Docker image to $(REPO)"
	gcloud docker -- push $(REPO)/$(NAME):$(TAG)

default: build

clean:
	@echo "Cleaning up local Docker images"
	docker rmi -f $(NAME) $(REPO)/$(NAME):$(TAG) || true
