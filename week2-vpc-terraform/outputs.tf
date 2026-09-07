
output "deploying_to_account" {
  value = data.aws_caller_identity.current.account_id
}
