###############################################################################
# Amazon RDS for MySQL in the isolated DB subnets.
# Credentials are generated here, stored in Secrets Manager, and injected into
# the containers by ECS at start-up - they never appear in the image or repo.
###############################################################################

resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#%^*()-_=+[]{}:?" # excludes chars RDS rejects (/ @ " space)
}

resource "aws_secretsmanager_secret" "db" {
  name_prefix             = "${local.name}-db-"
  description             = "FruitBazar MySQL credentials (read by ECS at task start)"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "mysql"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db-subnets"
  subnet_ids = aws_subnet.db[*].id
  tags       = { Name = "${local.name}-db-subnets" }
}

resource "aws_db_parameter_group" "main" {
  name_prefix = "${local.name}-mysql-"
  family      = "mysql${var.db_engine_version}"
  description = "FruitBazar MySQL parameters"

  parameter {
    name  = "require_secure_transport"
    value = "1" # reject unencrypted connections
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4" # handles the rupee sign and emoji in product data
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_0900_ai_ci"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${local.name}-mysql"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  backup_retention_period    = var.db_backup_retention_days
  backup_window              = "18:30-19:30"         # 00:00-01:00 IST
  maintenance_window         = "sun:20:00-sun:21:00" # Mon 01:30-02:30 IST
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "${local.name}-mysql-final"

  tags = { Name = "${local.name}-mysql" }
}
