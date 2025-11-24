# 🛒 E-Commerce Multi-Platform Project

A full-stack e-commerce solution integrating **Spring Boot** (Core Backend), **Django** (Auth & Telegram Bot), and **Flutter** (Mobile App).

## 📋 Prerequisites

*   Python 3.x
*   Java JDK (Compatible with Spring Boot version)
*   Flutter SDK
*   Stripe Account (for API Keys)
*   Telegram Bot Token
*   Tunneling tools (Ngrok, Cloudflare Tunnel)

---

## 🚀 Installation & Setup

### 1. Django Setup (Auth & Telegram Bot)

First, set up the Python environment and install dependencies.

```bash
cd django-project-folder
# Create virtual env (optional)
python -m venv venv
# Windows: venv\Scripts\activate | Mac/Linux: source venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Run Migrations and Start
python manage.py migrate
python manage.py runserver
```

### 2. Spring Boot Setup (Core API & Stripe)

Navigate to your Spring Boot project and configure your environment credentials.

    Open src/main/resources/application.properties.

    Inject your Database credentials and Stripe Keys.

    Configure the Stripe Redirect URLs to point to your application host (see the Networking section below).

    # application.properties example
```properties
# Database
spring.datasource.url=jdbc:mysql://localhost:3306/your_db
spring.datasource.username=your_user
spring.datasource.password=your_password

# Stripe Config
stripe.api.key=sk_test_your_key...
stripe.success.url=https://<your-spring-boot-host>/payment-success
stripe.cancel.url=https://<your-spring-boot-host>/payment-cancel
```

### 3. Networking, Tunnels & Webhooks

Since this project uses external webhooks (Stripe & Telegram), you must expose your local servers to the internet.

Recommended Setup:

    Django: Use Ngrok (Free Tier)

    Spring Boot: Use Cloudflare Tunnel

A. Stripe Webhook (Connect to Spring Boot)

    Expose your Spring Boot app (e.g., via Cloudflare).

    Create a webhook in your Stripe Dashboard.

    Set the destination URL:

    https://<your-spring-boot-domain>/stripe-webhook
    # Example: https://phsakhmer.com/stripe-webhook

B. Telegram Bot Webhook (Connect to Django)

    Expose your Django app (e.g., via Ngrok).

    You must manually register the webhook with the Telegram API.

    The destination URL format is:

    https://<your-django-ngrok-domain>/api/auth/webhook
    # Example: https://random-id.ngrok-free.app/api/auth/webhook
(Note: Research setWebhook for the Telegram API to configure this).

### 4. Flutter App Configuration

Finally, configure the mobile app to talk to your exposed backend URLs.

    Navigate to lib/utils/app_constants.dart.

    Update the static strings with your Tunnel/Host URLs.

⚠️ IMPORTANT: Enter the base URL without the trailing /api.

// lib/utils/app_constants.dart

class AppConstants {
  
  // Your Spring Boot Host (Cloudflare/Live URL)
  // ❌ Incorrect: https://phsakhmer.com/api
  // ✅ Correct:   https://phsakhmer.com
  static const String kApiHostSpring = 'https://your-spring-boot-url.com';

  // Your Django Host (Ngrok URL)
  // ❌ Incorrect: https://phsakhmer.com/api
  // ✅ Correct:   https://phsakhmer.com
  static const String kApiHostDjango = 'https://your-django-ngrok-url.app';

}
