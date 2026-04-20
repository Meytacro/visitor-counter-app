output "elastic_ip" {
  value = aws_eip.visitor_counter_ip.public_ip
}

output "public_dns" {
  value = aws_instance.visitor_counter.public_dns
}
