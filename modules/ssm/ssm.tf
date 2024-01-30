# configuration parameter
resource "aws_ssm_parameter" "rcv_meta" {
  name        = "/rcv/meta"
  description = "Meta information for current RCV stream."
  type        = "String"
  value       = "1"
  tags = {
    Name = "rcv-meta"
  }
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}