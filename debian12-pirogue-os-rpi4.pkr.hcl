packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.5"
      source  = "github.com/solo-io/arm-image"
    }
  }
}


source "arm-image" "pirogue-os" {
  iso_checksum      = "sha256:a68cd2bfe7831c438d8a5d832803ae0db17afec9f3cd370d9e8748c7b5456283"
  iso_url           = "https://raspi.debian.net/tested/20230612_raspi_4_bookworm.img.xz"
  image_type        = "raspberrypi"
}

build {
  source "source.arm-image.pirogue-os" {
    name = "pirogue-os"
  }

  provisioner "shell" {
    script = "./debian-12/script.sh"
  }

  post-processor "shell-local" {
    environment_vars = [
      "image_flavor=Pi3_and_Pi4"
    ]
    script = "./debian-12/post.sh"
    keep_input_artifact = true
  }
}
