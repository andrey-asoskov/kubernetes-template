solution       = "kubernetes"
solution_short = "k8s"
env            = "dev"

asg_worker_instance_type = "t3.small"
asg_worker_ImageName     = "ami-08c40ec9ead489470" //Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-09-12
asg_worker_DesiredSize   = 1
asg_worker_MaxSize       = 3
asg_worker_MinSize       = 1
asg_worker_shutoff       = "true"
asg_worker_backup        = "false"
