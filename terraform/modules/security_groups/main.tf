//Security groups 

////////////            ALB-SG       //////////////
resource "aws_security_group" "alb_sg" {
  name = "ALB-SG"

  #   vpc_id = aws_vpc.vpc_ecs_url.id
  vpc_id = var.vpc_id
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-ingress-http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = var.allow_all_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb-ingress-https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = var.allow_all_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "alb-egress-to-ecs" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}



//////////////////// ECS SG  ////////////////////////

resource "aws_security_group" "ecs_sg" {
  name = "ecs-sg"

  vpc_id = var.vpc_id

  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-alb-traffic" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}



resource "aws_vpc_security_group_egress_rule" "ecs-egress-to-endpoints" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.endpoints_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_all_egress" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

///////////// vpc endpoints sg ///////////////////////

//////////////////// ECS SG  ////////////////////////

resource "aws_security_group" "endpoints_sg" {
  name = "endpoints-sg"

  vpc_id = var.vpc_id

  tags = {
    Name = "endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ecs-traffic" {
  security_group_id            = aws_security_group.endpoints_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}



resource "aws_vpc_security_group_egress_rule" "allow-all-outbound" {
  security_group_id = aws_security_group.endpoints_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
