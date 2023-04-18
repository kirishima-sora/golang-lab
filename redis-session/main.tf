terraform {
    #AWSプロバイダーのバージョン指定
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.51.0"
        }
    }
}
#AWSプロバイダーの定義
provider aws {
    region = "ap-northeast-1"
}

# 既存のVPC
variable vpc_id {
    type = string
    # 使用するVPCのID
    default = "<VPC ID>"
}

# サブネットの作成
resource aws_subnet redis_subnet {
    vpc_id = var.vpc_id
    # Redisを配置するプライベートサブネットのCIDRブロック
    cidr_block = "<Redis Private Subnet CIDR block>"
}
# セキュリティグループの作成
resource aws_security_group redis_sg {
    name_prefix = "redis-sg"
    ingress {
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        # EC2を配置しているパブリックサブネットのCIDRブロック
        cidr_blocks = ["<EC2 CIDR block>"]
    }
}

# Redisの作成
resource aws_elasticache_subnet_group redis_subnet_group {
    name       = "redis-subnet-group"
    subnet_ids = [aws_subnet.redis_subnet.id]
}
resource aws_elasticache_cluster redis_cluster {
    cluster_id           = "redis-cluster"
    engine               = "redis"
    engine_version       = "7.0"
    node_type            = "cache.t4g.micro"
    num_cache_nodes      = 1
    subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
    security_group_ids   = [aws_security_group.redis_sg.id]
}

