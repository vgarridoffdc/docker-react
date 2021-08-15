# SHARED
DOCKER_ID_TAG = "vgarridoff/"
VERSION_TAG = "latest"

BUILD_DOCKER_COMPOSE:
	@echo "\n\n Building docker compose $(DOCKER_COMPOSE_PATH) \n\n"
	@docker-compose \
		-f ${DOCKER_COMPOSE_PATH} \
		build

RUN_DOCKER_COMPOSE:
	make BUILD_DOCKER_COMPOSE
	@echo "\n\n Running docker compose $(DOCKER_COMPOSE_PATH) \n\n"
	@docker-compose \
		-f ${DOCKER_COMPOSE_PATH} \
		up

ATTACH_TO_CONTAINER_BY_ID:
	@echo "\n\n >>>> Attaching to container ID ${DOCKER_CONTAINER_ID} <<< \n\n"
	@docker exec -it ${DOCKER_CONTAINER_ID} sh

ATTACH_TO_CONTAINER_BY_NAME:
	@echo "\n\n >>> Attaching to container name $(DOCKER_CONTAINER_TAG) <<< \n\n"
	DOCKER_CONTAINER_ID=$(shell docker ps | grep ${DOCKER_CONTAINER_TAG} | awk '{ print $$1 }') \
	make ATTACH_TO_CONTAINER_BY_ID

BUILD_IMAGE_WITH_DOCKERFILE:
	@echo "\n\n  >>> BUILDING $(DOCKER_TAG) <<<  \n\n"
	@docker build \
		-t ${DOCKER_TAG} \
		-f ${DOCKERFILE_PATH} \
		${DOCKER_BUILD_CONTEXT}

RUN_IMAGE_WITH_DOCKERFILE:
	make BUILD_IMAGE_WITH_DOCKERFILE
	@echo "\n\n  >>> RUNNING $(DOCKER_TAG) <<<  \n\n"
	@docker run \
		-p ${LOCAL_PORT}:${CONTAINER_PORT} \
		-it \
		-v ${APP_PWD}:/home/node/app \
		-v /home/node/app/node_modules \
		${DOCKER_TAG}

RUN_IMAGE_WITH_DOCKERFILE_CI:
	make BUILD_IMAGE_WITH_DOCKERFILE
	@echo "\n\n  >>> RUNNING $(DOCKER_TAG) <<<  \n\n"
	@docker run \
		-p ${LOCAL_PORT}:${CONTAINER_PORT} \
		-it \
		-e CI=true \
		-v ${APP_PWD}:/home/node/app \
		-v /home/node/app/node_modules \
		${DOCKER_TAG}

REACT_DOCKERFILE = ./docker/Dockerfile.dev
REACT_TEST_DOCKERFILE = ./docker/Dockerfile.test.dev
REACT_PROD_DOCKERFILE = ./docker/Dockerfile.prod

REACT_DOCKERFILE_CONTEXT = .

REACT_TAG = "${DOCKER_ID_TAG}reactapp:${VERSION_TAG}"
REACT_TEST_TAG = "${DOCKER_ID_TAG}reactapptest:${VERSION_TAG}"
REACT_PROD_TAG = "${DOCKER_ID_TAG}reactappprod:${VERSION_TAG}"

APP_PORT = 3000
NGINX_PORT = 80
APP_PWD = $(shell pwd)

REACT_DOCKER_COMPOSE = ./docker/docker-compose.yml

REACT_BUILD_DOCKERFILE:
	DOCKERFILE_PATH=${REACT_DOCKERFILE} \
	DOCKER_TAG=${REACT_TAG} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	make BUILD_IMAGE_WITH_DOCKERFILE

REACT_PROD_BUILD_DOCKERFILE:
	DOCKERFILE_PATH=${REACT_PROD_DOCKERFILE} \
	DOCKER_TAG=${REACT_PROD_DOCKERFILE} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	make BUILD_IMAGE_WITH_DOCKERFILE

REACT_RUN_DOCKERFILE:
	DOCKERFILE_PATH=${REACT_DOCKERFILE} \
	DOCKER_TAG=${REACT_TAG} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	CONTAINER_PORT=${APP_PORT} \
	LOCAL_PORT=${APP_PORT} \
	make RUN_IMAGE_WITH_DOCKERFILE

REACT_PROD_RUN_DOCKERFILE:
	DOCKERFILE_PATH=${REACT_PROD_DOCKERFILE} \
	DOCKER_TAG=${REACT_PROD_TAG} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	CONTAINER_PORT=${NGINX_PORT} \
	LOCAL_PORT=${APP_PORT} \
	make RUN_IMAGE_WITH_DOCKERFILE

REACT_RUN_TEST_DOCKERFILE:
	make REACT_BUILD_DOCKERFILE
	DOCKERFILE_PATH=${REACT_TEST_DOCKERFILE} \
	DOCKER_TAG=${REACT_TEST_TAG} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	CONTAINER_PORT=${APP_PORT} \
	LOCAL_PORT=${APP_PORT} \
	make RUN_IMAGE_WITH_DOCKERFILE

REACT_RUN_TEST_DOCKERFILE_CI:
	make REACT_BUILD_DOCKERFILE
	DOCKERFILE_PATH=${REACT_TEST_DOCKERFILE} \
	DOCKER_TAG=${REACT_TEST_TAG} \
	DOCKER_BUILD_CONTEXT=${REACT_DOCKERFILE_CONTEXT} \
	CONTAINER_PORT=${APP_PORT} \
	LOCAL_PORT=${APP_PORT} \
	make RUN_IMAGE_WITH_DOCKERFILE_CI

REACT_BUILD:
	DOCKER_COMPOSE_PATH=${REACT_DOCKER_COMPOSE} \
	make BUILD_DOCKER_COMPOSE

REACT_RUN:
	DOCKER_COMPOSE_PATH=${REACT_DOCKER_COMPOSE} \
	make RUN_DOCKER_COMPOSE

REACT_DEBUG:
	DOCKER_CONTAINER_TAG=${REACT_TAG}  \
	make ATTACH_TO_CONTAINER_BY_NAME

REACT_TAG_ECHO:
	@echo ${REACT_TAG}