target "docker-metadata-action" {}

target "beets" {
  inherits   = ["docker-metadata-action"]
  context    = "./docker/beets"
  dockerfile = "./docker/beets/Dockerfile"
}
