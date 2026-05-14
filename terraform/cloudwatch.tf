resource "aws_cloudwatch_dashboard" "visitor_counter" {
  dashboard_name = "visitor-counter-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ALB Request Count"
          region = var.aws_region
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.visitor_counter_alb.arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Request Count per Target"
          region = var.aws_region
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCountPerTarget",
              "TargetGroup",
              aws_lb_target_group.visitor_counter_tg.arn_suffix,
              "LoadBalancer",
              aws_lb.visitor_counter_alb.arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Target Response Time"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.visitor_counter_alb.arn_suffix
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Healthy / Unhealthy Targets"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup",
              aws_lb_target_group.visitor_counter_tg.arn_suffix,
              "LoadBalancer",
              aws_lb.visitor_counter_alb.arn_suffix
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              ".",
              ".",
              "."
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "EC2 CPU Utilization"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              aws_autoscaling_group.visitor_counter_asg.name
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "Auto Scaling Group Capacity"
          region = var.aws_region
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/AutoScaling",
              "GroupDesiredCapacity",
              "AutoScalingGroupName",
              aws_autoscaling_group.visitor_counter_asg.name
            ],
            [
              ".",
              "GroupInServiceInstances",
              ".",
              "."
            ],
            [
              ".",
              "GroupMinSize",
              ".",
              "."
            ],
            [
              ".",
              "GroupMaxSize",
              ".",
              "."
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          title  = "HTTP 4XX / 5XX Errors"
          region = var.aws_region
          period = 60
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_4XX_Count",
              "LoadBalancer",
              aws_lb.visitor_counter_alb.arn_suffix
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              ".",
              "."
            ],
            [
              ".",
              "HTTPCode_ELB_4XX_Count",
              ".",
              "."
            ],
            [
              ".",
              "HTTPCode_ELB_5XX_Count",
              ".",
              "."
            ]
          ]
        }
      }
    ]
  })
}