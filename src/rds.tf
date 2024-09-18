# Data source para verificar se o Security Group já existe
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["db_sg"]
  }
  
  # Adicionando um ignore_errors para evitar falhas se o SG não existir
  lifecycle {
    ignore_errors = true
  }
}

# Variável local para verificar se o Security Group já existe
locals {
  sg_exists = length(data.aws_security_group.existing_sg.id) > 0
}

# Recurso para criar o Security Group se ele não existir
resource "aws_security_group" "db_sg" {
  count = local.sg_exists ? 0 : 1
  name = "db_sg"
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
  db_name                = var.db_name
  identifier             = var.db_name
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  publicly_accessible    = true
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = local.sg_exists ? [data.aws_security_group.existing_sg.id] : [aws_security_group.db_sg[0].id]
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [db_name]
  }

  tags = {
    Name = var.db_name
  }
}