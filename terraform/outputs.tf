output "asg_name" {
  value = aws_autoscaling_group.visitor_counter_asg.name
}

output "target_group_arn" {
  value = data.aws_lb_target_group.visitor_counter_tg.arn
}