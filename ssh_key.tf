resource "tls_private_key" "key" {
  for_each  = var.ami
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  for_each        = var.ami
  key_name_prefix = "${each.key}-"
  public_key      = tls_private_key.key[each.key].public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key[each.key].private_key_pem}' > ./keys/${each.key}.pem && chmod 600 ./keys/${each.key}.pem"
  }
  tags = {
    git_file = "ssh_key.tf"
    git_org  = "managedkaos"
    git_repo = "nginx-development-environment"
  }
}
