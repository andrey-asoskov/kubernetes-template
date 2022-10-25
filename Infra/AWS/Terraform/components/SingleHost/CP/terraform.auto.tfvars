solution       = "kubernetes"
solution_short = "k8s"
env            = "dev"

asg_control_plane_instance_type = "t3.small"
asg_control_plane_ImageName     = "ami-08c40ec9ead489470" //Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-09-12
asg_control_plane_DesiredSize   = 1
asg_control_plane_MaxSize       = 1
asg_control_plane_MinSize       = 1
asg_control_plane_shutoff       = "true"
asg_control_plane_backup        = "false"
