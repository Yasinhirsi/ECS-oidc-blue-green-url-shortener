///////////////////////// VPC ENDPOINTS /////////////////////////////////////////////////

//GATEWAY ENDPOINT (routing level)

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [var.private_route_table_id]
  tags = {
    Environment = "s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "DynamoDB" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = [var.private_route_table_id]
  //implict defaulting 
  tags = {
    Environment = "dynamodb-endpoint"
  }
}


// INTERFACE Endpoints 

resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecs"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoints_sg_id]
  private_dns_enabled = true //very important line, make note
  vpc_endpoint_type   = "Interface"

  tags = {
    Name = "ecs-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoints_sg_id]
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"


  tags = {
    Name = "ecr-endpoint"
  }
}


resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoints_sg_id]
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"

  tags = {
    Name = "logs-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoints_sg_id]

  tags = {
    Name = "ecr-api-endpoint"
  }
}


