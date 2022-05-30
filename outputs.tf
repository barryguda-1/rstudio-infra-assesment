output "R-Studio-Public-IP" {
  value = aws_instance.rstudio-master.public_ip
}
