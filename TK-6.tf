provider "aws"{
  region = "ap-south-1"
  profile= "fate"
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "fatedb"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "fatedb"
  username = "fate"
  password = "fatekilledkn"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["sg-0f8b0534894154741"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "fate"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = ["subnet-caecd6a2", "subnet-8f7c17c3"]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "fatedb"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

output "out" {
    value = "Endpoint id is ${module.db.this_db_instance_endpoint} , Database Name : ${module.db.this_db_instance_name} , username : ${module.db.this_db_instance_username} , Password: ${module.db.this_db_instance_password} ,  Port : ${module.db.this_db_instance_port}"
}

resource "aws_instance" "fateos1" {


	ami = "ami-052c08d70def0ac62"
	instance_type = "t2.micro"
	key_name = "eks"
	vpc_security_group_ids = ["sg-0f8b0534894154741"]
    subnet_id = "subnet-caecd6a2"

tags = {
	Name = "WP"
	}
   }

resource "null_resource" "null_att"  {

depends_on = [
    aws_instance.fateos1,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("D:/eks.pem")
    host     = aws_instance.fateos1.public_ip
  }



provisioner "remote-exec" {
    inline = [
      "sudo yum -y install docker" ,
      "sudo systemctl start docker" ,
      "sudo docker pull wordpress" ,
      "sudo docker run --name wp -p 8080:80 -d wordpress" ,
    ]
  }
}
output "ou" {
    value ="The IP of WordPress is  ${aws_instance.fateos1.public_ip}:8080 "
}