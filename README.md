# 🚀 Visitor Counter App

A simple cloud-native visitor counter application built from scratch and deployed to production using modern DevOps tools.

## 🌐 Overview

This project demonstrates the full lifecycle of a cloud application:

* Local development
* Containerization
* Cloud deployment
* Infrastructure as Code
* Scaling with load balancing

The application counts visits and stores them in Redis, exposing a simple API consumed by a frontend.

---

## 🧱 Architecture

```
Client (Browser)
        │
        ▼
Application Load Balancer (AWS)
        │
        ▼
Auto Scaling Group (EC2 instances running Docker)
        │
        ▼
Flask Backend (Python)
        │
        ▼
Redis (AWS ElastiCache)
```

---

## ⚙️ Tech Stack

* **Backend:** Python (Flask)
* **Database:** Redis (ElastiCache)
* **Containerization:** Docker
* **Cloud Provider:** AWS (EC2, ALB, Auto Scaling)
* **Infrastructure as Code:** Terraform
* **CI/CD:** GitHub Actions
* **Networking:** VPC + Security Groups

---

## 📦 Features

* Visitor counter stored in Redis
* REST API (`/visits`)
* Health check endpoint (`/health`)
* Containerized backend
* Deployed on AWS EC2
* Load balanced with ALB
* Auto Scaling enabled
* Infrastructure fully managed with Terraform

---

## 🚀 Deployment Flow

1. Build Docker image
2. Push image to Docker Hub
3. Terraform provisions infrastructure:
   * EC2 / Auto Scaling Group
   * Load Balancer
   * Security Groups
4. EC2 instances pull and run the container
5. Application becomes publicly accessible

---

## 🔄 CI/CD

GitHub Actions automates:

* Building Docker image
* Pushing to Docker Hub

(Next step: automatic deployment + instance refresh)

---

## 📁 Project Structure

```
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
```

---

## 🧠 What I Learned

* How to deploy a real application in AWS
* Container lifecycle with Docker
* Infrastructure provisioning with Terraform
* Load balancing and scaling concepts
* How Auto Scaling Groups replace manual EC2 management
* Basics of CI/CD pipelines

---

## 🌍 Live Demo

👉 https://visitcounterapp.com

---

## 📌 Future Improvements

* Automatic deployment (CI/CD → ASG refresh)
* HTTPS with ACM + Route53
* Custom domain
* Monitoring (CloudWatch dashboards)
* Logging improvements
* Blue/Green deployments

---

## 🤝 Contributing

This is a personal learning project, but suggestions are welcome.

---

## 📄 License

MIT License

---

## 👤 Author

**Marc Ropero Soberbio**

Cloud & DevOps enthusiast building real-world projects.

---
