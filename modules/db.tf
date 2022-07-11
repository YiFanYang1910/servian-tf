resource "aws_db_instance" "servian_postgres_db" {
    identifier = "servian-identifier"
    #Identifier for RDS instance
    engine = "postgres"
    engine_version = "14.1"
    instance_class = "db.t3.micro"
    allocated_storage = "10"
    storage_type = "gp2"
    #type of underlying storage for database
    name = var.db_name
    username = "servianjames"
    password = "servian123"
    backup_retention_period = "30"
    #number of days for database backup
    backup_window = "01:00-01:30"
    maintenance_window = "sun:01:30-sun:02:30"
    auto_minor_version_upgrade = true
    skip_final_snapshot = true
    multi_az = false
    port = "8888"
    vpc_security_group_ids = [aws_security_group.servian_secgroup_task_definition.id]
}