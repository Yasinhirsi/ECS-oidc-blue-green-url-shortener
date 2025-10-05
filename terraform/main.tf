module "networking" {
  source = "./modules/networking"

  vpc_cidr          = var.vpc_cidr
  public_sub1_cidr  = var.public_sub1_cidr
  public_sub2_cidr  = var.public_sub2_cidr
  private_sub1_cidr = var.private_sub1_cidr
  private_sub2_cidr = var.private_sub2_cidr

  subnet_1_az = var.subnet_1_az
  subnet_2_az = var.subnet_2_az

  allow_all_cidr = var.allow_all_cidr
}

module "security_groups" {
  source = "./modules/security_groups"

  // from networking outputs
  vpc_id = module.networking.vpc_id

  // from root variables
  allow_all_cidr = var.allow_all_cidr
  vpc_cidr       = var.vpc_cidr
}

module "endpoints" {
  source                 = "./modules/endpoints"
  region                 = var.region
  vpc_id                 = module.networking.vpc_id
  private_route_table_id = module.networking.private_route_table_id
  private_subnet_ids     = module.networking.private_subnet_ids
  endpoints_sg_id        = module.security_groups.endpoints_sg_id
}

module "alb" {
  source                     = "./modules/alb"
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  alb_sg_id                  = module.security_groups.alb_sg_id
  app_port                   = 8080
  healthcheck_path           = "/healthz"
  enable_deletion_protection = false
  certificate_arn            = data.aws_acm_certificate.cert.arn
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "url-shortener"
}

module "codedeploy" {
  source                = "./modules/codedeploy"
  app_name              = "url-shortener-codedeploy-app"
  deployment_group_name = "url-shortener-dg"
  cluster_name          = module.ecs.cluster_name
  service_name          = module.ecs.service_name
  listener_arn          = module.alb.https_listener_arn
  blue_tg_name          = "blue-tg"
  green_tg_name         = "green-tg"
}
module "ecs" {
  source       = "./modules/ecs"
  cluster_name = "url-short-ecs"
  family       = "url-shortener"
  cpu          = 256
  memory       = 512
  image        = "487148038595.dkr.ecr.eu-west-2.amazonaws.com/url-shortener:20250930-191534"
  app_port     = 8080

  aws_region        = var.region
  log_stream_prefix = "ecs"

  table_name    = module.dynamodb.table_name
  ddb_table_arn = module.dynamodb.table_arn

  private_subnet_ids = module.networking.private_subnet_ids
  ecs_sg_id          = module.security_groups.ecs_sg_id

  target_group_arn = module.alb.blue_tg_arn
  desired_count    = var.desired_count
}

module "oidc" {
  source = "./modules/oidc"

  github_repo = var.github_repo
}

