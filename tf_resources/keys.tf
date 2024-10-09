resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "kp" {
  key_name   = var.key_pair
  public_key = trimspace(tls_private_key.pk.public_key_openssh)

  provisioner "local-exec" { # Create .pem key on your computer
    command = "echo '${trimspace(tls_private_key.pk.private_key_pem)}' > ./${var.key_pair}.pem; chmod 0400 ./${var.key_pair}.pem"
  }
}
