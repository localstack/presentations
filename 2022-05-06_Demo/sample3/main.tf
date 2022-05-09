resource "aws_db_instance" "default" {
  db_name              = "test"
  username             = "test"
  password             = "test"
  engine               = "aurora-postgresql"

  allocated_storage    = 10
  instance_class       = "db.t3.micro"
  skip_final_snapshot  = true
}
