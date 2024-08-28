variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
    description = ""
    type = string
}

variable "launch_config_wipro" {
    default = "demo"
    description = ""
    type = string
}


variable "pub_sub_cidr_block" {
    default = ["10.0.1.0/24", "10.0.2.0/24"]
    description = "public cidr block"
    type = list(string)
}

variable "pri_sub_cidr_block" {
    default = ["10.0.3.0/24", "10.0.4.0/24"]
    description = "Private cidr block"
    type = list(string)
}

variable "az" {
    default = ["eu-west-1a", "eu-west-1b"]
    type = list(string)
}

variable "pub_subnet_tags" {
    default = ["public-1", "public-2"]
}

variable "pri_subnet_tags" {
    default = ["public-1", "public-2"]
}



