variable "name" {}

resource "local_file" "foo" {
  content     = "foo! ${var.name}"
  filename = "${path.module}/foo.bar"
}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "cat ${path.module}/foo.bar"
  }
}

output "file_contents" {
  value = "foo! ${var.name}"
}