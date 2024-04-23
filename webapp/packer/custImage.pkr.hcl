packer {
  required_plugins {
    googlecompute = {
      version = ">= 1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "centos8" {
  project_id          = "assignment-4-414719"
  source_image_family = "centos-stream-8"
  zone                = "us-central1-a"
  ssh_username        = "pkr_ssh"
  network             = "default"

}

build {
  sources = ["source.googlecompute.centos8"]

  provisioner "file" {
    source      = "systemd/csye6225.service"
    destination = "/tmp/csye6225.service"
  }

  provisioner "file" {
    source      = "webappFork.zip"
    destination = "/tmp/webappFork.zip"
    generated   = true
  }

  provisioner "file" {
    source      = "packer/script/config.yaml"
    destination = "/tmp/config.yaml"
    generated   = true
  }

  provisioner "shell" {
    scripts = [
      "packer/script/mainScript.sh",
      "packer/script/opsAgentScript.sh"
    ]
  }
}