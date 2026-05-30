output "alb_sg_id" { value = aws_security_group.alb.id }
output "tomcat_sg_id" { value = aws_security_group.tomcat.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "eks_sg_id" { value = aws_security_group.eks.id }