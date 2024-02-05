data "external" "get_sg_id" {
  program = ["bash", "${path.module}/find_sg.sh"]

  depends_on = [ aws_eks_node_group.prod_node_group ]
}

//SECURITY GROUP
resource "aws_security_group" "secgrp_rds" {

  name        = "secgrp-rds"
  description = "Allow MySQL Port"
  vpc_id      = aws_vpc.this.id
 
  ingress {
    description = "Allowing Connection for MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [data.external.get_sg_id.result["sg_id"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tuktuk-RDS"
  }
  depends_on = [ data.external.get_sg_id ]
}

// subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name = "db-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "tuktuk-RDS"
  }
  depends_on = [ aws_security_group.secgrp_rds ]
}

//RDS INSTANCE
resource "aws_db_instance" "rds" {
  identifier             = "rds"
  instance_class         = "db.t3.micro"
  storage_type           = "gp3"
  allocated_storage      = 200
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = var.mysql_root_username
  password               = var.mysql_root_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.secgrp_rds.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  depends_on = [ aws_db_subnet_group.db_subnet ]
}