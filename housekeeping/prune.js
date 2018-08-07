{
  "source": "https://gitlab.com/mudler/Mottainai-test",
  "image": "spotify/docker-gc",
  "directory": "/",
  "script": ["/docker-gc"],
  "task": "docker_execute",
  "prune": "yes",
  "planned": "@daily",
  "environment" : ["REMOVE_VOLUMES=1", "FORCE_IMAGE_REMOVAL=1", "FORCE_CONTAINER_REMOVAL=1","GRACE_PERIOD_SECONDS=1"],
  "binds": [ "/etc:/etc:ro" ]
}
