## VPC, Subnets, Routetable

This weeks labs objective was to create the following
1. 1 VPC, 2 Subnets, one private and one public
2. Launch 2 EC2 instances and attach one each to the private and public subnets
3. Create a internet gateway and attach it to the public subnet
3. Configure a route table whose traffic to the internet (the destination) is 0.0.0.0/0 and the Target is the internet gateway that was created.


What happened
All the following were created using the desktop aws gui
### VPC creation
1. VPC only option was used, named "Lab-VPC"
2. A IPv4 CIDR block was given - 10.0.0.0/16 (which meant the first 16 bits from the left were frozen and there are 65536 possible IP addresses)

### Subnet creation
All the following steps were the same for the public and private subnets, except for their names and the IPv4 subnet CIDR blocks. Both were in the same availablity zone
1. subnet names were "public-subnet" and "private-subnet"
2. Availablity Zone - "us-east-1a"
3. IPv4 VPC CIDR block - 10.0.0.0/16
4. IPv4 subnet CIDR block for public subnet 10.0.1.0/24 and for private subnet 10.0.2.0/24

### Internet Gateway creation
Internet gateway creation was quite staright forward, only the name had to be given. "Lab-internet-gateway" was the name given to mine.

### Route Table creation
A new Route Table name "Lab-route-table" was created and only "public-subnet" was associated with it. For the "Destination" 0.0.0.0/0 (the internet) the Target was "Lab-internet-gateway". This simply meant in the "public-subnet" route all traffic to the internet via the "Lab-internet-gateway"

### EC2 instances creation
2 instances were created with amazon linux as its os and t3 micro (free tier eligible).A key pair was created once and the same was used for both instances. It was named "public-ec2" (It should have been named better, but thats ok)

Both instances were attached to the "Lab-VPC".
"public-ec2" instance was attached to "public-subnet" and "private-ec2" was attached to "private-subnet"

2 Security groups were created. Both allowed SSH connection from anywhere in the internet to start with. They were named "Lab-public-SG" and "private-SG" respectively (here again the naming conventions are to be taken care of..)


### What did I experiment
1. Was I able to SSH into my "public-ec2"? Yes
2. Was I able to SSH into my "private-ec2"?
	No. 
	This is expected.
3. Did "ProxyJump" in the ssh config file help logging into the "private-ec2"?
	Yes.
	"private-ec2" allowed connections from within the VPC.
	So using proxyjump does exactly this. Step 1 it ssh into the "public-ec2", then		in from there it ssh into "private-ec2"

4. The Target in the "Lab-route-table" was altered from "Lab-internet-gateway" to "public-ec2", what happend to ssh?
	Actually after i modified this, I could not see a output saying that i logged in successfully into the "public-ec2". 
	What had happened is, once the target in the route table was modified, the output from the "public-ec2" could not reach my laptop, but the communication from my laptop was able to reach the instance. This happened because, modification in the route table did NOT affect the traffic going to the "public-subnet"(therefore my "pubic-ec2"), but since the traffic from the "public-subnet" was directed to the "public-ec2", i could not see the "success for the ssh".
	This was better visualized when the "Lab-route-table" Target was modified whileI was pinging 8.8.8.8 after a successful login into the "public-ec2". The output stream froze in my terminal once the route table was misconfigured, again when the route table was configured back correctly, the output stream started scrolling again for the ping command.  

