# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
		  # COMPLETE ME complete the "name" argument below to use Ubuntu 24.04
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # COMPLETE ME add inline scripts to create necessary directories and change directory ownership	
      "sudo mkdir -p /etc/nginx/sites-available",
      "sudo mkdir -p /etc/nginx/sites-enabled",
      "sudo mkdir -p /var/www/html",
      "sudo mkdir -p /tmp/web",
      "sudo chown -R ubuntu:www-data /var/www/html", 
      "sudo chmod -R 755 /var/www/html",
      "sudo chown ubuntu:root /etc/nginx",
      "sudo chmod -R 755 /etc/nginx",
      "sudo chown -R ubuntu:root /usr/local/bin",
      "sudo chown -R ubuntu:root /tmp"		
    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source = "./files/index.html"
    destination = "/var/www/html/index.html"	
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source = "./files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks
  provisioner "file" {
    source = "./scripts/install-nginx"
    destination = "/usr/local/bin/install-nginx"
  }
  provisioner "file" { 
    source = "./scripts/setup-nginx"
    destination = "/usr/local/bin/setup-nginx"
  }
  provisioner "shell" {
    inline = [
        "chmod +x /usr/local/bin/install-nginx",
	"chmod +x /usr/local/bin/setup-nginx",
	"sudo /usr/local/bin/install-nginx",
	"sudo /usr/local/bin/setup-nginx"
	
   ] 
  }
}

