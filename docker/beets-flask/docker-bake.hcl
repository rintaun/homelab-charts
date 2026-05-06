target "docker-metadata-action" {}

target "beets-flask" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./docker/beets-flask/Dockerfile"

  matrix = {
    app_version   = ["stable", "latest"]
    beets_version = ["default", "2.11.0"]
  }

  # Matrix entries must have unique target names and only use valid identifier chars.
  name = "beets-flask-${replace(app_version, ".", "_")}-${replace(beets_version, ".", "_")}"

  args = {
    APP_VERSION   = app_version
    BEETS_VERSION = beets_version
  }

  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
