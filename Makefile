REGISTRATION_TOKEN?=YourTokenFromGitlabSettingsCIRunner
IMG=docker:dind

prepare:
	sudo mkdir -p /srv/gitlab-runner/config
	docker volume create gitlab-runner-docker-executor-ca ||:
	docker volume create gitlab-runner-docker-executor-client ||:

gitlabrunner-register:
	docker run --rm -it -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner \
	register -n \
	--url https://gitlab.com/ \
	--registration-token $(REGISTRATION_TOKEN) \
	--executor docker \
	--description "dind-runner" \
	--docker-image "$(IMG)" \
	--docker-volumes "gitlab-runner-docker-executor-client:/certs/client" \
	--docker-volumes "gitlab-runner-docker-executor-ca:/certs/ca" \
	--docker-privileged

gitlabrunner-run:
	docker stop gitlab-runner-docker-executor ||:
	docker rm gitlab-runner-docker-executor ||:
	docker run -d --name gitlab-runner-docker-executor --restart always \
	-v /srv/gitlab-runner/config:/etc/gitlab-runner \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--privileged gitlab/gitlab-runner

gitlabrunner-exec:
	docker exec -it gitlab-runner-docker-executor sh

gitlabrunner-logs:
	docker logs gitlab-runner-docker-executor

gitlabrunner-follow:
	docker logs --follow gitlab-runner-docker-executor

