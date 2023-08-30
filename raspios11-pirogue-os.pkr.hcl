packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.5"
      source  = "github.com/solo-io/arm-image"
    }
  }
}


source "arm-image" "pirogue-os" {
  iso_checksum      = "sha256:bf982e56b0374712d93e185780d121e3f5c3d5e33052a95f72f9aed468d58fa7"
  iso_url           = "https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz"
}

build {
  source "source.arm-image.pirogue-os" {
    name = "pirogue-os"
  }

  provisioner "shell" {
    script = "./raspi-os-11/script.sh"
  }

  post-processor "shell-local" {
    script = "./raspi-os-11/post.sh"
    keep_input_artifact = true
  }
}
