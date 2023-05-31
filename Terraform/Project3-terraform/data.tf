data "aws_availability_zones" "availability_zone" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ssm_parameter" "instance_ami" {
  name = "/aws/service/canonical/ubuntu/eks/18.04/1.17/stable/20211004/amd64/hvm/ebs-gp2/ami-id"
}