target "docker-metadata-action" {}

target "image" {
  inherits   = ["docker-metadata-action"]
  context    = "./docker/beets"
  dockerfile = "./docker/beets/Dockerfile"
}
