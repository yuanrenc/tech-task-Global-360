### 1. How to run a plan
Option A - Run via GitHub Actions
1. Go to GitHub → Actions
2. Select the workflow named Terraform Check
3. Click Run workflow
(When a pull request is opened or updated, this workflow runs automatically and posts the Terraform plan output directly as a comment on the PR. Please refer to the example below: https://github.com/yuanrenc/tech-task-Global-360/pull/1)

Option B - Run locally
```Bash
cd terraform
make plan
```

### 2. Architecture
The task comes with three key requirements:

    It must operate without downtime.

    It must support self‑healing.

    The total cost must remain ≤ AUD 20 when fully deployed.

Meeting all three simultaneously is extremely challenging. If we only consider the first two requirements, the ideal architecture would be ALB + ASG with two EC2 instances running in parallel. This setup provides true zero downtime and automatic self‑healing, but the cost would exceed the budget. If the ASG runs only a single instance, then achieving zero downtime becomes nearly impossible. On the other hand, without using an ALB, it is also difficult to use an ASG effectively, because CloudFront requires static IPs and ASG instances cannot guarantee that, which means self‑healing would not function properly.

Ultimately, the approach I chose prioritizes meeting the cost requirement while still providing the best possible level of zero downtime, at the expense of full self‑healing capabilities.

Based on all the considerations above, I chose the following architecture:

```text
                    ┌─────────────────────────┐
                    │      End Users          │
                    │    (Web Browsers)       │
                    └───────────┬─────────────┘
                                │
                                │ HTTPS
                                ▼
                    ┌─────────────────────────┐
                    │   Amazon CloudFront    │
                    │   (CDN Distribution)   │
                    │   - Global Edge        │
                    │   - Failover Routing   │
                    └───────────┬─────────────┘
                                │
                                │ HTTP (Origin)
                                ▼
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    ┌─────────────────────┐       ┌─────────────────────┐
    │  Availability Zone A│       │  Availability Zone B│
    │  ┌───────────────┐  │       │  ┌───────────────┐  │
    │  │ Public Subnet │  │       │  │ Public Subnet │  │
    │  │               │  │       │  │               │  │
    │  │ ┌───────────┐ │  │       │  │ ┌───────────┐ │  │
    │  │ │ EC2       │ │  │       │  │ │ EC2       │ │  │
    │  │ │ Instance  │ │  │       │  │ │ Instance  │ │  │
    │  │ │ (Primary) │ │  │       │  │ │ (Backup)  │ │  │
    │  │ └───────────┘ │  │       │  │ └───────────┘ │  │
    │  └───────────────┘  │       │  └───────────────┘  │
    └─────────────────────┘       └─────────────────────┘

    CloudFront Origin Configuration:
    - Primary Origin: EC2 Instance #1 (AZ-A)
    - Secondary Origin: EC2 Instance #2 (AZ-B)
    - Failover on health check failure
    - Security: CloudFront-only access via Security Group
```
This is a simple architecture where CloudFront provides a stable endpoint and performs primary–secondary failover routing before directing traffic to EC2. The EC2 layer runs in an active‑active configuration to ensure minimal downtime. Because the Cloudfront require public IP/DNS, instances are deployed in public subnets. Security Groups are configured to ensure that only CloudFront is allowed to access the instances.

Regarding the CI setup, granting the correct permissions in a public repository requires careful consideration. I used an OIDC + IAM Role approach, allowing only specific branches and pull‑request events to assume the role. The role is restricted to read‑only permissions to maximize security.

If you are interested in the ASG + ALB architecture, I have deployed a working version of it in the ASG+ALB branch. In this design, the Auto Scaling Group provides automatic self‑healing, and the ALB distributes traffic across two different Availability Zones. One thing to note is that the EC2 instances need to download the Docker image from the internet, and due to cost constraints, the application does not use a private‑subnet‑plus‑NAT‑Gateway setup. Instead, the instances are placed in public subnets to avoid the additional cost of a NAT Gateway.

The ASG+ALB architecture as following:

```text
                    ┌─────────────────────────┐
                    │      End Users          │
                    │    (Web Browsers)       │
                    └───────────┬─────────────┘
                                │
                                │ HTTPS
                                ▼
                    ┌─────────────────────────┐
                    │   Amazon CloudFront    │
                    │                        │
                    │   - Global Edge        │
                    │                        │
                    └───────────┬─────────────┘
                                │
                                │ Origin HTTP
                                ▼
                    ┌─────────────────────────┐
                    │  Application Load       │
                    │  Balancer (ALB)         │
                    │  - Public Subnets       │
                    │  - Cross-AZ             │
                    └───────────┬─────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
    ┌─────────────────────┐       ┌─────────────────────┐
    │  Availability Zone A│       │  Availability Zone B│
    │  ┌───────────────┐  │       │  ┌───────────────┐  │
    │  │ Public Subnet │  │       │  │ Public Subnet │  │
    │  │               │  │       │  │               │  │
    │  │ ┌───────────┐ │  │       │  │ ┌───────────┐ │  │
    │  │ │ EC2       │ │  │       │  │ │ EC2       │ │  │
    │  │ │ Instance  │ │  │       │  │ │ Instance  │ │  │
    │  │ │ (ASG)     │ │  │       │  │ │ (ASG)     │ │  │
    │  │ └───────────┘ │  │       │  │ └───────────┘ │  │
    │  └───────────────┘  │       │  └───────────────┘  │
    └─────────────────────┘       └─────────────────────┘

    Auto Scaling Group (ASG):
    - Min: 2, Max: 2, Desired: 2
    - Health Check: ELB
    - Automatic instance replacement on failure
    - Security: CloudFront-only access via Security Group
```

### 3.monthly cost

The estimated monthly cost for the current architecture is approximately USD $10. This estimate includes:
- 2 EC2 t2.nano instances ($10)

For ALG+ASG architecture, the apporximately cost is USD $28. This includes:
- 2 EC2 t2.nano instances ($10)
- 1 ALB ($18)



