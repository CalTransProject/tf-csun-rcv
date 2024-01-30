# default table
resource "aws_dynamodb_table" "rcv" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "StreamId"
  range_key    = "Time"
  tags = {
    Name = var.name
  }

  attribute {
    name = "StreamId"
    type = "N"
  }

  attribute {
    name = "Time"
    type = "N"
  }
}
