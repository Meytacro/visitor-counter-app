# 🚀 Visitor Counter App

Production-ready cloud application deployed on AWS with a full DevOps workflow, including HTTPS, custom domain, load balancing and auto scaling.

---

## 🌐 Live Demo

👉 https://visitcounterapp.com

---

## 📌 Project Overview

This project demonstrates how to design, build and deploy a scalable backend service using modern cloud and DevOps practices.

The application exposes a simple API that tracks the number of visits using Redis as a persistent store, served through a fully managed cloud infrastructure.

---

## 🧱 Architecture

```mermaid
flowchart TD
    A[Client / Browser] -->|HTTPS| B[ACM Certificate]
    B --> C[Application Load Balancer]
    C --> D[Auto Scaling Group]
    D --> E1[EC2 Instance - Docker + Flask backend]
    D --> E2[EC2 Instance - Docker + Flask backend]
    E1 --> F[Redis - AWS ElastiCache]
    E2 --> F
```

---

## 🔄 CI/CD Flow

```mermaid
flowchart LR
    A[Push] --> B[GitHub Actions]
    B --> C[Build Image]
    C --> D[Push Image]
    D --> E[Refresh ASG]
    E --> F[New EC2]
    F --> G[Pull Image]
    G --> H[Route Traffic]
    H --> I[Terminate Old]
```

---

## ⚙️ Tech Stack

| Layer            | Technology                |
| ---------------- | ------------------------- |
| Backend          | Python (Flask)            |
| Database         | Redis (ElastiCache)       |
| Containerization | Docker                    |
| Cloud            | AWS (EC2, ALB, ASG, ACM)  |
| IaC              | Terraform                 |
| CI/CD            | GitHub Actions            |
| Domain & HTTPS   | Custom domain + SSL (ACM) |

---

## ✨ Key Features

* REST API with visit counter (`/visits`)
* Health check endpoint (`/health`)
* Stateless backend architecture
* Redis-based persistence
* Dockerized application
* Infrastructure provisioned with Terraform
* Load balancing with AWS Application Load Balancer
* Auto Scaling Group for high availability
* HTTPS enabled with custom domain (`visitcounterapp.com`)
* Zero-downtime deployments using Instance Refresh
* Fully automated CI/CD pipeline

---

## 🚀 Deployment Workflow

### 🔄 What happens on every push

1. Code is pushed to GitHub  
2. GitHub Actions builds the Docker image  
3. Image is pushed to Docker Hub  
4. AWS triggers an Auto Scaling Instance Refresh  
5. New EC2 instances are launched  
6. Instances pull the latest image automatically  
7. Load Balancer routes traffic to new instances  
8. Old instances are terminated  

👉 No manual intervention required  
👉 Fully automated rolling deployments  

---

## 🔄 CI/CD Pipeline

The pipeline is fully automated and reproducible:

- Docker image build  
- Push to Docker Hub  
- Automatic deployment on AWS  
- Rolling updates via Auto Scaling Group (Instance Refresh)  

### 🎯 Trigger conditions

The pipeline runs only when relevant files change:

- `backend/**`  
- `Dockerfile`  
- `docker-compose.prod.yml`  
- `.github/workflows/**`  

👉 Avoids unnecessary deployments (e.g. README changes)  
👉 Ensures efficient and controlled releases 

---

## 📁 Project Structure

```text
cloudproject/
├── backend/
│   ├── backend.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── static/
│   │   ├── navigator_logo.png
│   │   ├── preview.png
│   │   └── web_logo.png
│   └── templates/
├── terraform/
│   ├── main.tf
│   └── user_data.sh
└── README.md
```

---

## 📸 Preview

![App Preview](backend/static/preview.png)

---

## 🧠 Engineering Decisions

### Why Redis?

* In-memory storage → extremely fast
* Ideal for counters
* Managed service (ElastiCache) reduces operational overhead

### Why HTTPS + Custom Domain?

* Real production setup
* Secure communication (SSL/TLS)
* Professional deployment (not raw IP)

### Why Auto Scaling Group?

* Eliminates manual EC2 management
* Provides high availability
* Enables rolling updates with zero downtime

### Why Terraform?

* Infrastructure reproducibility
* Version-controlled cloud configuration
* Prevents configuration drift

### Why Docker?

* Consistent execution environment
* Simplifies deployment process
* Enables CI/CD automation

---

## 📊 What This Project Demonstrates

* End-to-end cloud deployment
* Infrastructure as Code (IaC)
* Containerized backend services
* Load balancing and horizontal scaling
* Stateless architecture with externalized state
* Fully automated CI/CD pipeline
* Rolling deployments with zero downtime
* Reproducible cloud infrastructure

---

## 🔮 Future Improvements

* Monitoring and alerting (CloudWatch)
* Centralized logging
* Blue/Green deployments
* Security improvements (IAM, networking)
* CDN (CloudFront)
* API protection and rate limiting

---

## 👤 Author

**Marc Ropero Soberbio**

Cloud & DevOps Engineer (in progress) focused on building real-world infrastructure projects.

---

## 📄 License

MIT License
