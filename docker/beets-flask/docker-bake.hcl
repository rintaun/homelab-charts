target "docker-metadata-action" {}

target "image" {
  inherits   = ["docker-metadata-action"]
  dockerfile = "./Dockerfile"

  matrix = {
    app_version   = ["stable", "latest"]
    beets_version = ["", "2.11.0"]
  }

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
