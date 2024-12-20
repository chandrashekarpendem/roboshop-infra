env = "dev"
default_vpc_id ="vpc-017e4ed2b0978fa6f"
allow_bastion_cidr = ["172.31.36.166/32"]

vpc = {
  main = {
    cidr_block="10.0.0.0/16"
    availability_zone = ["us-east-1a", "us-east-1b"]

      public_subnets = {
        public = {
          name              = "public"
          cidr_block        = ["10.0.0.0/24", "10.0.1.0/24"]
          internet_gw       = true
        }
      }

     private_subnets = {

       web={
         name              = "web"
         cidr_block        = ["10.0.2.0/24", "10.0.3.0/24"]
         nat_gw            = true
       }

       app={
         name              = "app"
         cidr_block        = ["10.0.4.0/24", "10.0.5.0/24"]
         nat_gw            = true

       }

       db= {
         name              = "db"
         cidr_block        = ["10.0.6.0/24", "10.0.7.0/24"]
         nat_gw            = true


       }
     }



    }
  }

  docdb = {
    main = {
      vpc_name = "main"
      subnets_name = "db"
      engine_version = "4.0.0"
      number_of_instances= 1
      instance_class = "db.t3.medium"
    }

  }

  rds = {
    main = {
      vpc_name              = "main"
      subnets_name          = "db"
      engine                = "aurora-mysql"
      engine_version        = "5.7.mysql_aurora.2.11.1"
      number_of_instance   = 1
      instance_class        = "db.t3.small"
    }

  }

rabbitmq = {
  main = {
    vpc_name = "main"
    subnets_name = "db"
    component = "rabbitmq"

  }
}

elastic_cache_redis = {
  main = {
    vpc_name        = "main"
    subnets_name    = "db"
    node_type       = "cache.t3.micro"
    num_cache_nodes = 1
    engine_version = "6.x"
  }

}

alb = {
    public = {
      vpc_name      = "main"
      subnets_type  = "public_subnets_ids"
      subnets_name  = "public"
      internal      = false

  }

  private = {
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    internal      = true
  }
}


apps = {
  frontend = {
    component     = "frontend"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "web"
    app_port      = 80
    allow_cidr_subnets_type = "public_subnets"
    allow_cidr_subnets_name = "public"
    instances_type = "t3.micro"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "public"
    listener_priority = 0
  }

  catalogue = {
    component     = "catalogue"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    app_port      = 8080
    allow_cidr_subnets_type = "private_subnets"
    allow_cidr_subnets_name = "app"
    instances_type = "t3.micro"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "private"
    listener_priority = 100
  }

  cart = {
    component     = "cart"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    app_port      = 8080
    instances_type = "t3.micro"
    allow_cidr_subnets_type = "private_subnets"
    allow_cidr_subnets_name = "app"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "private"
    listener_priority = 101
  }
  user = {
    component     = "user"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    instances_type = "t3.micro"
    app_port      = 8080
    allow_cidr_subnets_type = "private_subnets"
    allow_cidr_subnets_name = "app"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "private"
    listener_priority = 102
  }
  shipping = {
    component     = "shipping"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    instances_type = "t3.micro"
    app_port      = 8080
    allow_cidr_subnets_type = "private_subnets"
    allow_cidr_subnets_name = "app"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "private"
    listener_priority = 103
  }
  payment = {
    component     = "payment"
    vpc_name      = "main"
    subnets_type  = "private_subnets_ids"
    subnets_name  = "app"
    instances_type = "t3.micro"
    app_port      = 8080
    allow_cidr_subnets_type = "private_subnets"
    allow_cidr_subnets_name = "app"
    desired_capacity = 1
    max_size = 2
    min_size = 1
    alb = "private"
    listener_priority = 104
  }
}