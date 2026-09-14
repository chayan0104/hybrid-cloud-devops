output "alb_dns" { value = module.alb.alb_dns_name }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "rds_endpoint" { value = module.rds.endpoint }
output "weblogic_private_ip" { value = module.weblogic.private_ip }