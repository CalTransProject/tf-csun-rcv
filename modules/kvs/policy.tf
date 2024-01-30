# KVS write access
resource "aws_iam_policy" "kvs_write_access" {
  name = "RcvKinesisVideoStreamsWriteAccess"
  tags = {
    Name = "${var.name}-write-access"
  }
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kinesisvideo:PutMedia",
          "kinesisvideo:DescribeStream",
          "kinesisvideo:GetDataEndpoint"
        ],
        "Resource" : [aws_kinesis_video_stream.rcv.arn]
      }
    ]
  })
}

# kvs producer
resource "aws_iam_user" "kvs_producer" {
  name = "${var.name}-producer"
  tags = {
    Name = "${var.name}-producer"
  }
}

# policy attachment
resource "aws_iam_policy_attachment" "kvs_producer" {
  for_each = {
    1 = aws_iam_policy.kvs_write_access.arn
  }
  name       = "AmazonKinesisVideoStreams${each.key}"
  users      = [aws_iam_user.kvs_producer.name]
  policy_arn = each.value
}