target "docker-metadata-action" {}

target "beets" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./docker/beets/Dockerfile"
}
