## Terraform learnings
There should always be .gitignore which holds the following
*.tfstate
*.tfstate.backup
*.tfvars

Always run terraform plan before apply.

There should be a output which shows to which aws account the infrastructure changes are being affected to

The AWS_PROFILE shoule be exported as an environment variable and not be hardcoded in the terraform code

The providers.tf contains a default_tags which will applied to all resources by default (I have the project_tag here)

Tags are very important and NOT a nice to have.
	- When someone wants list resource based on a project it helps a lot
	- Especially billing, terraform destroy etc..


## Routes
1. A gateway (aws_internet_gateway is one such gateway) is an exit door which has a label (cidr block) which says which all traffic anc pass through this door. 
2. A route table (aws_route_table) is something which is a set of rules which defines traffic towards which cidr block exits through which gateway. 
3. The ways to associate a route table with a subnet is by using aws_route_table_association

4. Inside a route_table there can be multiple routes be defined. For example

```
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  # Route 1: general internet traffic
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Route 2: traffic destined for the peered "logging" VPC
  route {
    cidr_block                = "172.31.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.to_logging_vpc.id
  }

  tags = {
    Name = "week2-lab-public-route-table"
  }
}
```
There can be overlaps in the CIDR blocks, notice that here to there is a overlap between the cidr_blocks, first route says if the traffic is directed to any IP address sent it to the internet gateway, the second route says if the traffic is directed to a much more specific block 172.31.0.0/16 (This has got a longer prefix that the 0.0.0.0/0) the route it through vpc_peering_connection_id. In such case when a packet arrives, aws applies these rules, NOT in order of the appearance in code, but rather by which route has a longer prefix (much more specific CIDR blocks). So even though 172.31.0.0/16 is part of the 0.0.0.0/0, when a packet arrives with a destination 172.31.1.1 then this packet will be routed to vpc_peering_connection_id.