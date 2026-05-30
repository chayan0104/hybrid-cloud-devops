output "alb_dns" { value = module.alb.alb_dns_name }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "rds_endpoint" { value = module.rds.endpoint }
output "tomcat_private_ip" { value = module.tomcat.private_ip }