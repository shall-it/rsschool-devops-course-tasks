
# resource "aws_instance" "test_stack" {
#   count                       = 4
#   ami                         = data.aws_ami.al2023-ami.id
#   instance_type               = var.instance_type
#   subnet_id                   = element([aws_subnet.public_a_az.id, aws_subnet.public_b_az.id, aws_subnet.private_a_az.id, aws_subnet.private_b_az.id], count.index)
#   vpc_security_group_ids      = [aws_security_group.test_stack.id]
#   key_name                    = aws_key_pair.kp.key_name
#   user_data_replace_on_change = true
#   user_data = templatefile("${path.module}/userdata.sh", {
#     cidr_blocks = join(" ", [
#       aws_subnet.public_a_az.cidr_block,
#       aws_subnet.public_b_az.cidr_block,
#       aws_subnet.private_a_az.cidr_block,
#       aws_subnet.private_b_az.cidr_block
#     ])
#   })
#   depends_on = [aws_subnet.public_a_az, aws_subnet.public_b_az, aws_subnet.private_a_az, aws_subnet.private_b_az]
# }

# resource "aws_instance" "bastion" {
#   ami                    = data.aws_ami.al2023-ami.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public_a_az.id
#   vpc_security_group_ids = [aws_security_group.bastion.id]
#   key_name               = aws_key_pair.kp.key_name
#   depends_on             = [aws_subnet.public_a_az]
# }

# output "public_a_az_public_ip" {
#   value = aws_instance.test_stack[0].public_ip
# }

# output "public_b_az_public_ip" {
#   value = aws_instance.test_stack[1].public_ip
# }

# output "bastion_public_ip" {
#   value = aws_instance.bastion.public_ip
# }
