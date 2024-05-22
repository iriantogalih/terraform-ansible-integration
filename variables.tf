variable "instance_type" {
  type= string   
  default = "t2.micro"
}

variable "ami_linux" {
    type=string
    default =  "ami-003c463c8207b4dfa"  
}

variable "enable_public" {
    type = bool
    default = true
}