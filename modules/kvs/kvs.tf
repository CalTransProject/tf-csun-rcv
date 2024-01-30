# kvs stream
resource "aws_kinesis_video_stream" "rcv" {
  name                    = var.name
  data_retention_in_hours = 1
  media_type              = "video/h264"
  tags = {
    Name = var.name
  }
}