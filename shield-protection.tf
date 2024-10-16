resource "aws_shield_protection" "shield" {
  count = var.enable_shield_protection == true && var.enable_load_balancer ? 1 : 0

  name         = var.family
  resource_arn = aws_lb.alb.0.arn
}
