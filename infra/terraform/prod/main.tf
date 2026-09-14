locals {
  name_prefix = "enterprise-prod"
}

module "network" {
  source = "../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security" {
  source = "../modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "weblogic" {
  source = "../modules/weblogic-ec2"

  name_prefix       = local.name_prefix
  subnet_id         = module.network.private_subnet_ids[0]
  security_group_id = module.security.weblogic_sg_id
  instance_type     = var.instance_type
  ami_id            = var.weblogic_ami_id
  key_name          = var.weblogic_key_name
}

module "alb" {
  source = "../modules/alb"

  name_prefix                 = local.name_prefix
  vpc_id                      = module.network.vpc_id
  public_subnet_ids           = module.network.public_subnet_ids
  alb_security_group_id       = module.security.alb_sg_id
  weblogic_target_instance_id = module.weblogic.instance_id
  acm_certificate_arn         = var.acm_certificate_arn
}

module "eks" {
  source = "../modules/eks"

  name_prefix             = local.name_prefix
  subnet_ids              = module.network.private_subnet_ids
  cluster_security_group_id = module.security.eks_sg_id
  cluster_role_arn        = var.eks_cluster_role_arn
  node_role_arn           = var.eks_node_role_arn
  kms_key_arn             = var.eks_kms_key_arn
}

module "rds" {
  source = "../modules/rds"

  name_prefix          = local.name_prefix
  subnet_ids           = module.network.private_subnet_ids
  db_security_group_id = module.security.rds_sg_id
  db_password          = var.db_password
}
