output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = "us-east-1"
}
//private ip
output "private_ip" {
 value = aws_instance.diplom_instance.*.private_ip
}
//public ip
output "public_ip" {
 value = aws_instance.diplom_instance.*.public_ip
}