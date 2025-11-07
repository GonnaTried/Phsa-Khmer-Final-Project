from django.urls import path

from .views import PhoneOTPInitiateView  # New
from .views import PhoneOTPVerifyView  # New
from .views import (
    CheckTelegramStatusView,
    FinalRegistrationView,
    InitiateTelegramFlowView,
    TelegramWebhookView,
    UserProfileView,
)

urlpatterns = [
    path("initiate/", InitiateTelegramFlowView.as_view(), name="initiate_login"),
    path("webhook/", TelegramWebhookView.as_view(), name="telegram_webhook"),
    path("final/", FinalRegistrationView.as_view(), name="final_registration"),
    path("phone/initiate/", PhoneOTPInitiateView.as_view(), name="phone_otp_initiate"),
    path("phone/verify/", PhoneOTPVerifyView.as_view(), name="phone_otp_verify"),
    path("profile/", UserProfileView.as_view(), name="user_profile"),
    path("check/", CheckTelegramStatusView.as_view(), name="check_telegram_status"),
]
