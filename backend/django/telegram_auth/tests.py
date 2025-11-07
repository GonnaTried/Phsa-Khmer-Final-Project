from datetime import timedelta
from unittest import mock

from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APIClient

# Import your models and constants
from telegram_auth.models import OTP, CustomUser
from telegram_auth.views import _send_telegram_message  # Import the function to mock

# --- URL Names (Based on the suggested urls.py) ---
INITIATE_URL = "initiate_login"
PHONE_INITIATE_URL = "phone_otp_initiate"
PHONE_VERIFY_URL = "phone_otp_verify"


class OTPAuthTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.phone_number_linked = "+85512345678"
        self.phone_number_unlinked = "+85599999999"

        # User with linked Telegram account
        self.user_linked = CustomUser.objects.create_user(
            username="linkeduser",
            password="password123",
            phone_number=self.phone_number_linked,
            telegram_chat_id="10001",
        )

        # User without linked Telegram account
        self.user_unlinked = CustomUser.objects.create_user(
            username="unlinkeduser",
            password="password123",
            phone_number=self.phone_number_unlinked,
            telegram_chat_id=None,
        )

    # --- Phone OTP Initiate Tests ---

    @mock.patch("telegram_auth.views._send_telegram_message")
    def test_initiate_otp_success_telegram(self, mock_send):
        """Test OTP generation and Telegram delivery for a linked user."""

        response = self.client.post(
            reverse(PHONE_INITIATE_URL),
            {"phone_number": self.phone_number_linked},
            format="json",
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("Telegram", response.data["message"])

        # Check if the Telegram helper was called and received the chat_id
        self.assertTrue(mock_send.called)
        self.assertEqual(mock_send.call_args[0][0], "10001")  # Check chat_id

        # Check if OTP was created in DB
        self.assertTrue(
            OTP.objects.filter(
                phone_number=self.phone_number_linked, is_used=False
            ).exists()
        )

    @mock.patch("telegram_auth.views._send_telegram_message")
    def test_initiate_otp_success_sms_fallback(self, mock_send):
        """Test OTP generation and fallback message for an unlinked user."""

        response = self.client.post(
            reverse(PHONE_INITIATE_URL),
            {"phone_number": self.phone_number_unlinked},
            format="json",
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("SMS (Fallback)", response.data["message"])

        # Check if the Telegram helper was NOT called (it fell back)
        self.assertFalse(mock_send.called)

    def test_initiate_otp_user_not_found(self):
        """Test initiation fails if phone number is unregistered."""
        response = self.client.post(
            reverse(PHONE_INITIATE_URL), {"phone_number": "+85500000000"}, format="json"
        )
        self.assertEqual(response.status_code, 404)
        self.assertIn("No account found", response.data["error"])

    # --- Phone OTP Verify Tests ---

    def create_otp(self, phone, code, minutes_valid=5):
        """Helper to create an OTP record."""
        return OTP.objects.create(
            phone_number=phone,
            code=code,
            expires_at=timezone.now() + timedelta(minutes=minutes_valid),
            is_used=False,
        )

    def test_verify_otp_success(self):
        """Test successful OTP verification and token issuance."""

        # 1. Generate OTP
        test_otp = "987654"
        self.create_otp(self.phone_number_linked, test_otp)

        # 2. Attempt verification
        response = self.client.post(
            reverse(PHONE_VERIFY_URL),
            {"phone_number": self.phone_number_linked, "otp_code": test_otp},
            format="json",
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("access_token", response.data)

        # 3. Check if OTP was marked as used
        self.assertTrue(
            OTP.objects.get(
                code=test_otp, phone_number=self.phone_number_linked
            ).is_used
        )

    def test_verify_otp_expired(self):
        """Test verification of an expired OTP."""

        # 1. Generate an expired OTP (set validity to -1 minute)
        expired_otp = "111111"
        self.create_otp(self.phone_number_linked, expired_otp, minutes_valid=-1)

        # 2. Attempt verification
        response = self.client.post(
            reverse(PHONE_VERIFY_URL),
            {"phone_number": self.phone_number_linked, "otp_code": expired_otp},
            format="json",
        )

        # Should fail with unauthorized error (Invalid OTP message is used for both invalid/expired for security)
        self.assertEqual(response.status_code, 401)
        self.assertIn("Invalid OTP", response.data["error"])

    def test_verify_otp_invalid_code(self):
        """Test verification with a totally incorrect code."""

        # 1. Generate valid OTP
        self.create_otp(self.phone_number_linked, "123456")

        # 2. Attempt verification with wrong code
        response = self.client.post(
            reverse(PHONE_VERIFY_URL),
            {"phone_number": self.phone_number_linked, "otp_code": "654321"},
            format="json",
        )

        self.assertEqual(response.status_code, 401)
        self.assertIn("Invalid OTP", response.data["error"])
