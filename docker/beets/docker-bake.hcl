target "docker-metadata-action" {}

target "local" {
  inherits   = ["docker-metadata-action"]
  context    = "./docker/beets"
  dockerfile = "./docker/beets/Dockerfile"
}
