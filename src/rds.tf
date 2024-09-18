resource "aws_security_group" "db_sg" {
  name_prefix = "db_sg-"
  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source para verificar se o DB já existe
data "aws_db_instance" "existing_db" {
  db_instance_identifier = "techchallenge"
}

# Variavel local para verificar se o DB já existe
locals {
  db_exists = length(data.aws_db_instance.existing_db.id) > 0
}

resource "aws_db_instance" "db_sg" {
  count = local.db_exists ? 0 : 1
  
  engine                 = "postgres"
  engine_version         = "14"
  db_name                = var.db-name
  identifier             = var.db-name
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  publicly_accessible    = true
  username               = var.db-username
  password               = var.db-password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  
  lifecycle {
    ignore_changes       = [db_name]
  }
  
  tags = {
    Name = var.db-name
  }
}