# PHSAKHMER E-COMMERCE PLATFORM

## 🎓 Final Year Project Submission (MIS, Java/Spring Boot, Python/Django, Flutter)

**Project Goal:** To develop a scalable, feature-rich C2C (Consumer-to-Consumer) e-commerce marketplace, similar in concept to eBay and Taobao, with a focus on a robust Microservice Architecture and a unified, cross-platform user experience.

---

## 💻 Technical Architecture

The platform follows a **Monorepo Microservice Architecture** to meet all project requirements:

| Component        | Technology                 | Primary Role / Focus                                                                                                                                      | Teacher Requirement          |
| :--------------- | :------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------- |
| **Frontend**     | **Flutter**                | **Unified UI/UX** for Web, Android, and iOS. Consumes APIs from both backend services.                                                                    | **Flutter Teacher**          |
| **Core Backend** | **Java Spring Boot**       | **Transactional Services:** Handles Authentication (JWT), User Management, **Order Processing, and the Escrow Payment System** (critical for trust).      | **Java Spring Boot Teacher** |
| **Data Backend** | **Python Django**          | **Intelligence Services:** Manages the **Product Catalog**, powers the **Search API**, and implements the **Recommendation Engine** for data-heavy tasks. | **Python Django Teacher**    |
| **Platform**     | **Microservices + Escrow** | **Overall System Design:** Focus on the business logic, data flow (DFD), system security, and the optional logistics integration strategy.                | **E-commerce / MIS Teacher** |

---

## 🛠️ Local Setup Guide

To run the entire system, you need **Java 21**, **Python 3.10+**, **Flutter SDK**, and an active terminal for each service.

### 1. Start the Core Backend (Spring Boot)

The core service runs on port `8080` (default).

```bash
cd backend/spring_boot
# If using Maven Wrapper (recommended)
./mvnw spring-boot:run
```
