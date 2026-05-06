target "docker-metadata-action" {}

target "beets-flask" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./Dockerfile"

  matrix = {
    app_version   = ["stable", "latest"]
    beets_version = ["", "2.11.0"]
  }

  # Matrix entries must have unique target names or Bake reports duplicate names.
  name = "beets-flask-${app_version}-${beets_version}"

  args = {
    APP_VERSION   = app_version
    BEETS_VERSION = beets_version
  }

  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]

  tags = concat(
    target.docker-metadata-action.tags, [
      "rintaun/beets-flask:${app_version}-${beets_version}"
    ]
  )
}
