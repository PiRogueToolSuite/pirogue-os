packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.5"
      source  = "github.com/solo-io/arm-image"
    }
  }
}


source "arm-image" "pirogue-os" {
  iso_checksum      = "sha256:883eb0006c8841b7950ef69a7bf55f73c2250ecc15e6bf507f39f0d82fa2ea0a"
  iso_url           = "https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-02-22/2023-02-21-raspios-bullseye-arm64-lite.img.xz"
}

build {
  source "source.arm-image.pirogue-os" {
    name = "pirogue-os"
  }

  provisioner "shell" {
    script = "./script.sh"
  }

  post-processor "shell-local" {
    script = "./post.sh"
    keep_input_artifact = true
  }
}
