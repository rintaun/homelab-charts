target "docker-metadata-action" {}

target "beets" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./Dockerfile"
  dockerfile = "./docker/beets/Dockerfile"
}
