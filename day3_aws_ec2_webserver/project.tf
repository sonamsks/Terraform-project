provider "aws" {
	region = "ap-south-1"
}

resource "aws_instance" "myweb" {

	ami = "ami-001843b876406202a"
	instance_type = "t2.micro"
	key_name = "tf_test"	
	tags = {
		Name = "SKS web server"
	}
}

resource "aws_ebs_volume" "ebs1" {

	size 		  = 2
	availability_zone = "ap-south-1a"
	tags = {
		Name = " SKS webserver extra volume"
	}
}

resource "aws_volume_attachment" "ebs_attach" {

	device_name = "/dev/sdb"
	volume_id = aws_ebs_volume.ebs1.id
	instance_id = aws_instance.myweb.id
}

resource "null_resource" "nullremote1" {
	connection {
	type 	= "ssh"
	user	= "ec2-user"
	private_key = file("C:/Users/sonam/Downloads/tf_test.pem")
	host		= aws_instance.myweb.public_ip
	}

	provisioner "remote-exec" {
	
		inline = [
			"sudo mkfs -t xfs	/dev/xvdb",
			"sudo yum install httpd -y",
			"sudo mount /dev/xvdb /var/www/html/",
			"sudo chown -R ec2-user /var/www/html",
			"sudo bash -c echo 'hello sonamwa' > /var/www/html/index.html",
			"sudo systemctl restart httpd"
			]
		}



}

resource "null_resource" "nulllocalchrome" {

		provisioner "local-exec"{
			command = "chrome http://${aws_instance.myweb.public_ip}/"
		}
} 

