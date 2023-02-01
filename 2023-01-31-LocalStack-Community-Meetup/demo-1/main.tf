provider "aws" {
  region = "us-east-1"
}

resource "aws_sqs_queue" "meetup_queue" {
    name = "meetup-queue"
}
