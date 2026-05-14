output "asg_name" {
  value = aws_autoscaling_group.visitor_counter_asg.name
}

output "target_group_arn" {
  value = aws_lb_target_group.visitor_counter_tg.arn
}

output "alb_dns_name" {
  value = aws_lb.visitor_counter_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.visitor_counter_alb.zone_id
}