target "docker-metadata-action" {}

target "image" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./Dockerfile"
}
