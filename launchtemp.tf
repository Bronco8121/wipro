resource "aws_launch_template" "wipro" {
    name_prefix = var.launch_config_wipro
    image_id = "ami-0c38b837cd80f13bb"
    instance_type = "t2.micro"
    vpc_security_group_ids =[aws_security_group.sg.id]
    key_name = "devops-key"
    user_data = filebase64("bootstrap.sh")
    #iam_instance_profile =var.iam_instance_profile

}