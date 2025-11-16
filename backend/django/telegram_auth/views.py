import random
import re
import string
import traceback
import uuid
from datetime import timedelta

import requests
from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import transaction
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.utils.text import slugify
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import (
    CODE_EXPIRY_MINUTES,
    OTP,
    STATE_TYPE_REGISTRATION,
    TelegramRegistrationState,
)

User = get_user_model()


def _send_telegram_message(chat_id, text):
    """Helper function to send a reply back to the user via the Telegram API."""
    # NOTE: In production, consider using Celery/Async to avoid blocking the webhook response.
    if not settings.TELEGRAM_BOT_TOKEN:
        print("TELEGRAM_BOT_TOKEN is not set.")
        return

    send_url = settings.TELEGRAM_API_URL + "sendMessage"
    payload = {"chat_id": chat_id, "text": text}

    try:
        requests.post(send_url, json=payload, timeout=5)
    except requests.exceptions.RequestException as e:
        print(f"Failed to send message to Telegram: {e}")


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        "access_token": str(refresh.access_token),
        "refresh_token": str(refresh),
    }


class InitiateTelegramFlowView(APIView):
    """
    Generates a unique one-time code to start either Login or Registration flow.
    Always creates a Registration state initially.
    """

    def post(self, request, *args, **kwargs):
        # Always initiate as a REGISTRATION flow. The status check will determine if it's actually a LOGIN.
        state_entry = TelegramRegistrationState.objects.create(
            state_type=STATE_TYPE_REGISTRATION
        )
        return Response(
            {"success": True, "one_time_code": str(state_entry.one_time_code)},
            status=status.HTTP_201_CREATED,
        )


class TelegramVerifyView(APIView):
    """
    Endpoint called by the Telegram Bot server
    to verify the one_time_code and link the Telegram chat ID.
    (This view is likely unused if you rely solely on the webhook deep link,
     but kept for completeness/API structure.)
    """

    def post(self, request, *args, **kwargs):
        code_str = request.data.get("code")
        chat_id = request.data.get("chat_id")

        if not code_str or not chat_id:
            return Response(
                {"error": "Missing 'code' or 'chat_id' in request."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            code_uuid = uuid.UUID(code_str)
        except ValueError:
            return Response(
                {"error": "Invalid one-time code format."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            state = TelegramRegistrationState.objects.get(one_time_code=code_uuid)
        except TelegramRegistrationState.DoesNotExist:
            return Response(
                {"error": "Invalid or non-existent registration code."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if state.is_expired():
            state.delete()
            return Response(
                {
                    "error": f"Registration code expired (valid for {CODE_EXPIRY_MINUTES} minutes)."
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if state.is_verified:
            return Response(
                {"message": "Code already verified."}, status=status.HTTP_200_OK
            )

        state.telegram_chat_id = chat_id
        state.is_verified = True
        state.save()

        return Response(
            {
                "message": "Telegram verification successful. User can now complete registration."
            },
            status=status.HTTP_200_OK,
        )


class CheckTelegramStatusView(APIView):
    """
    UNIFIED STATUS CHECK: Determines if the user is logging in (returns tokens) or registering (returns verified status).
    (Handles the GET to /api/auth/status/)
    """

    def get(self, request, *args, **kwargs):
        code_str = request.query_params.get("code")

        if not code_str:
            return Response(
                {"error": "Missing 'code' parameter."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            code_uuid = uuid.UUID(code_str)
        except ValueError:
            return Response(
                {"status": "invalid_code", "message": "Invalid code format."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            state = TelegramRegistrationState.objects.get(one_time_code=code_uuid)
        except TelegramRegistrationState.DoesNotExist:
            return Response(
                {"status": "invalid_code", "message": "Code not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if state.is_expired():
            state.delete()
            return Response(
                {"status": "expired", "message": "Window expired."},
                status=status.HTTP_403_FORBIDDEN,
            )

        if state.is_verified:
            # --- Successful Verification ---

            # 1. Check if a User already exists with this chat ID (Login/Existing User check)
            user = User.objects.filter(telegram_chat_id=state.telegram_chat_id).first()

            if user:
                # Flow 1: SUCCESSFUL LOGIN (ISSUES TOKENS)
                refresh = RefreshToken.for_user(user)
                state.delete()  # Clean up the state after token generation

                return Response(
                    {
                        "status": "success",
                        "registered": True,  # User is fully registered
                        "message": "Login successful.",
                        "access_token": str(refresh.access_token),
                        "refresh_token": str(refresh),
                    },
                    status=status.HTTP_200_OK,
                )

            else:
                # Flow 2: Successful Registration Binding (Ready for final details)
                return Response(
                    {
                        "status": "verified",
                        "registered": False,  # User needs to complete registration
                        "message": "Telegram verification complete. Proceed to final step.",
                    },
                    status=status.HTTP_200_OK,
                )

        # Default: Waiting for user interaction with the bot
        return Response(
            {"status": "pending", "message": "Awaiting Telegram interaction."},
            status=status.HTTP_200_OK,
        )


@method_decorator(csrf_exempt, name="dispatch")
class TelegramWebhookView(APIView):
    """
    Receives updates directly from the Telegram API via webhook.
    Handles user state management (Registered, Pending, New) and deep-link verification.
    """

    def post(self, request, *args, **kwargs):
        data = request.data
        chat_id = None

        try:
            if "message" not in data:
                return Response(status=status.HTTP_200_OK)

            message = data["message"]
            chat_id = str(message["chat"]["id"])
            text = message.get("text", "")

            print(f"WEBHOOK DEBUG: Processing message from chat_id={chat_id}")

            if not text.startswith("/start"):
                return Response(status=status.HTTP_200_OK)

            match = re.search(r"/start\s+([a-f0-9-]+)", text, re.IGNORECASE)

            # --- 1. Check User Status ---
            registered_user = User.objects.filter(telegram_chat_id=chat_id).first()

            if registered_user:
                print(
                    f"WEBHOOK DEBUG: User found in CustomUser table: {registered_user.username}"
                )

                if not match:
                    msg = f"👋 Welcome back, {registered_user.username}. Please use the specific login link from the app."
                    _send_telegram_message(chat_id, msg)
                    return Response(status=status.HTTP_200_OK)

                one_time_code_str = match.group(1)

                try:
                    state = TelegramRegistrationState.objects.get(
                        one_time_code=one_time_code_str,
                    )

                    with transaction.atomic():
                        if state.telegram_chat_id and state.telegram_chat_id != chat_id:
                            msg = "❌ This code is already linked to a different Telegram account."
                        elif state.is_expired():
                            state.delete()
                            msg = "❌ Login code expired. Please initiate login again from the app."
                        elif state.is_verified:

                            if not state.telegram_chat_id:
                                TelegramRegistrationState.objects.filter(
                                    telegram_chat_id=chat_id,
                                ).delete()
                                state.telegram_chat_id = chat_id
                                state.save(update_fields=["telegram_chat_id"])
                            msg = "✅ You are already logged in. Return to the app."
                        else:
                            TelegramRegistrationState.objects.filter(
                                telegram_chat_id=chat_id,
                            ).delete()
                            state.telegram_chat_id = chat_id
                            state.is_verified = True
                            state.save(
                                update_fields=["telegram_chat_id", "is_verified"]
                            )
                            msg = f"✅ Logged in as {registered_user.username}. Return to the app."

                except TelegramRegistrationState.DoesNotExist:
                    msg = "❌ Invalid login code. Please initiate login again from the app."

                _send_telegram_message(chat_id, msg)
                return Response(status=status.HTTP_200_OK)

            # --- 2. Process NEW Deep Link Verification (Registration or New Login) ---

            # --- CRITICAL NEW CLEANUP LOGIC ---

            # If we reach here, registered_user is None.
            # We look for *any* verified state linked to this chat_id.

            stale_states = TelegramRegistrationState.objects.filter(
                telegram_chat_id=chat_id,
            )

            if stale_states.exists():
                # This chat_id has a verified state, but no corresponding CustomUser record.
                # This implies a failed final registration, and the old state is stale/erroneous.
                print(
                    f"WEBHOOK DEBUG: Found {stale_states.count()} stale states for unregistered chat_id={chat_id}. Deleting them."
                )

                try:
                    with transaction.atomic():
                        TelegramRegistrationState.objects.filter(
                            telegram_chat_id=chat_id,
                        ).delete()
                    print("WEBHOOK DEBUG: Stale states successfully deleted.")
                except Exception as e:
                    print(f"WEBHOOK DEBUG: Failed to delete stale states: {e}")
                    # We still proceed, but log the error.

            # --- End CRITICAL NEW CLEANUP LOGIC ---

            if not match:
                msg = "Welcome! Please use the deep link from the registration page in the app."
                _send_telegram_message(chat_id, msg)
                return Response(status=status.HTTP_200_OK)

            one_time_code_str = match.group(1)

            # Find the new state created by InitiateTelegramFlowView
            try:
                new_state = TelegramRegistrationState.objects.get(
                    one_time_code=one_time_code_str
                )
            except TelegramRegistrationState.DoesNotExist:
                msg = "❌ Verification Failed: Invalid registration code."
                _send_telegram_message(chat_id, msg)
                return Response(status=status.HTTP_200_OK)

            user_data = message.get("from", {})
            telegram_username = user_data.get("username")
            telegram_first_name = user_data.get("first_name", "")
            telegram_last_name = user_data.get("last_name", "")

            # Since the cleanup logic ran above, we no longer need to check for
            # existing_verified_reg_state (Case B) because it should have been deleted
            # if the CustomUser record was missing.

            # If the user was PARTIALLY registered (Case B), the stale state was just deleted.
            # Therefore, we ONLY proceed to Case C (Standard New Account Binding).

            state = new_state

            if state.is_expired():
                state.delete()
                msg = (
                    f"❌ Error: Code expired (valid for {CODE_EXPIRY_MINUTES} minutes)."
                )
            elif state.is_verified:
                msg = "✅ You are already verified (bound to this code). Please return to the app."
            else:
                # Successful Binding (First time for this chat ID after cleanup)
                try:
                    with transaction.atomic():
                        state.telegram_chat_id = chat_id
                        state.telegram_username = telegram_username
                        state.telegram_first_name = telegram_first_name
                        state.telegram_last_name = telegram_last_name
                        state.is_verified = True
                        state.save()

                        msg = "✅ Binding successful! Please go back to the app to complete registration."
                except Exception as e:
                    print(f"WEBHOOK NEW BINDING UNIQUE CONSTRAINT ERROR: {e}")
                    msg = "❌ Verification failed. It looks like this Telegram account is already linked to another process. Please try logging in again."

            _send_telegram_message(chat_id, msg)

            return Response(status=status.HTTP_200_OK)

        except Exception as e:
            print(f"CRITICAL UNHANDLED WEBHOOK ERROR: {e}")
            print(traceback.format_exc())
            if chat_id:
                try:
                    _send_telegram_message(
                        chat_id,
                        "⚠️ Server Error: We experienced a technical issue. Please try again later.",
                    )
                except Exception:
                    pass
            return Response(status=status.HTTP_200_OK)


class FinalRegistrationView(APIView):
    """
    Endpoint for the client to submit final user details (phone)
    after successful Telegram verification.
    """

    def post(self, request, *args, **kwargs):
        code_str = request.data.get("code")
        phone_number = request.data.get("phone_number")

        # We assume first_name/last_name are optional inputs from the client (Platform Name)
        platform_first_name_input = request.data.get("first_name")
        platform_last_name_input = request.data.get("last_name")

        # --- 1. Validate Required Fields (Only code and phone_number needed) ---
        if not all([code_str, phone_number]):
            return Response(
                {"error": "Missing required fields (code, phone_number)."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 2. Retrieve the Verified State
        try:
            code_uuid = uuid.UUID(code_str)
        except ValueError:
            return Response(
                {"error": "Invalid code format."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        state = None
        try:
            state = TelegramRegistrationState.objects.get(
                one_time_code=code_uuid,
                is_verified=True,
                state_type=STATE_TYPE_REGISTRATION,
            )
        except TelegramRegistrationState.DoesNotExist:
            return Response(
                {
                    "error": "Verification failed, code expired, or code not found. Please restart the process."
                },
                status=status.HTTP_401_UNAUTHORIZED,
            )

        # 3. Check for Unique Phone Number
        if User.objects.filter(phone_number=phone_number).exists():
            return Response(
                {"error": "Phone number already registered."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # --- DETERMINE NAMES & USERNAME ---

        # Determine Public/Platform Names: Use user input, fall back to Telegram names
        final_first_name = platform_first_name_input or state.telegram_first_name or ""
        final_last_name = platform_last_name_input or state.telegram_last_name or ""

        # Construct a base username slug from the determined public name
        full_name = f"{final_first_name} {final_last_name}".strip()

        if not full_name:
            # Fallback if Telegram provided no name and client provided no name (use chat ID)
            base_username_slug = f"user_{state.telegram_chat_id}"
        else:
            base_username_slug = slugify(full_name)

        # --- UNIQUE USERNAME GENERATION ---

        # Check if the base slug already exists
        username_candidate = base_username_slug
        suffix = 0

        while User.objects.filter(username=username_candidate).exists():
            suffix += 1
            username_candidate = f"{base_username_slug}{suffix}"

        final_username = username_candidate

        # 4. Create the User Account (Without Password)
        try:
            user = User.objects.create_user(
                username=final_username,
                email=f"{state.telegram_chat_id}@telegram.ecom",
                first_name=final_first_name,
                last_name=final_last_name,
            )
            user.set_unusable_password()

            # 5. Save the custom fields
            user.phone_number = phone_number
            user.telegram_chat_id = state.telegram_chat_id

            # Populate Telegram reference fields
            user.telegram_username = state.telegram_username
            user.telegram_first_name = state.telegram_first_name
            user.telegram_last_name = state.telegram_last_name

            # Construct the Telegram link (requires models.py update)
            if hasattr(user, "telegram_profile_link") and state.telegram_username:
                user.telegram_profile_link = f"https://t.me/{state.telegram_username}"
            elif hasattr(user, "telegram_profile_link"):
                user.telegram_profile_link = None

            user.save()

            # 6. Clean up State
            state.delete()

            # 7. Generate JWT Tokens for Authentication
            refresh = RefreshToken.for_user(user)
            return Response(
                {
                    "message": "Registration successful!",
                    "user_id": user.pk,
                    "username": user.username,
                    "access_token": str(refresh.access_token),
                    "refresh_token": str(refresh),
                },
                status=status.HTTP_201_CREATED,
            )

        except Exception as e:
            print(f"User creation error: {e}")
            return Response(
                {"error": "Internal server error during user creation."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response(
            {
                "user_id": user.id,
                "username": user.username,
                "phone_number": user.phone_number,
                "telegram_username": (
                    user.telegram_first_name + " " + user.telegram_last_name
                    if user.telegram_first_name and user.telegram_last_name
                    else user.telegram_username
                ),
                "telegram_linked": hasattr(user, "telegram_chat_id")
                and bool(user.telegram_chat_id),
                "status": "Authenticated",
            }
        )


# OTP
MAX_OTP_ATTEMPTS = 5
LOCKOUT_DURATION_MINUTES = 10
OTP_COOLDOWN_SECONDS = 60


def generate_otp_code():
    # Generate 6 random digits
    return "".join(random.choices(string.digits, k=6))


class PhoneOTPInitiateView(APIView):
    """
    Sends a 6-digit OTP to the user's registered phone number via Telegram (if linked)
    or SMS (if necessary). Implements throttling per phone number.
    """

    def post(self, request):
        phone_number = request.data.get("phone_number")
        if not phone_number:
            return Response(
                {"error": "Phone number required."}, status=status.HTTP_400_BAD_REQUEST
            )

        # Check if user exists
        user = User.objects.filter(phone_number=phone_number).first()
        if not user:
            # Keep this generic for security
            return Response(
                {"error": "No account found with this phone number."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # --- NEW THROTTLING CHECK ---

        recent_otp = (
            OTP.objects.filter(phone_number=phone_number)
            .order_by("-created_at")
            .first()
        )

        if recent_otp:
            time_since_last_otp = (
                timezone.now() - recent_otp.created_at
            ).total_seconds()

            if time_since_last_otp < OTP_COOLDOWN_SECONDS:
                wait_time = int(OTP_COOLDOWN_SECONDS - time_since_last_otp)
                return Response(
                    {
                        "error": f"Please wait {wait_time} seconds before requesting a new code."
                    },
                    status=status.HTTP_429_TOO_MANY_REQUESTS,  # HTTP 429 status code is appropriate here
                )

        # --- EXISTING LOCKOUT CHECK ---
        if user.lockout_until and user.lockout_until > timezone.now():
            remaining_time = (user.lockout_until - timezone.now()).seconds // 60
            return Response(
                {"error": f"Account locked. Try again in {remaining_time} minutes."},
                status=status.HTTP_403_FORBIDDEN,
            )

        # Reset failed attempts if user successfully reached initiation stage after lockout expired
        if user.failed_login_attempts > 0:
            user.failed_login_attempts = 0
            user.save()

        # ... (rest of OTP generation and sending logic remains the same)

        otp_code = generate_otp_code()
        expiry_time = timezone.now() + timedelta(minutes=5)

        # 1. Create OTP record
        # Invalidate old codes for this phone number
        OTP.objects.filter(phone_number=phone_number, is_used=False).update(
            is_used=True
        )

        OTP.objects.create(
            phone_number=phone_number, code=otp_code, expires_at=expiry_time, user=user
        )

        # 2. Sending the OTP: Prioritize Telegram
        if user.telegram_chat_id:
            msg = f"Your Phsa Khmer Login Code is: {otp_code}. It expires in 5 minutes."
            _send_telegram_message(user.telegram_chat_id, msg)
            medium = "Telegram"
        else:
            # Fallback (requires external SMS service implementation)
            print(f"SMS FALLBACK REQUIRED: OTP {otp_code} for {phone_number}")
            medium = "SMS (Fallback)"

        return Response(
            {
                "message": f"OTP sent to {phone_number} via {medium}.",
                "phone_number": phone_number,
            },
            status=status.HTTP_200_OK,
        )


class PhoneOTPVerifyView(APIView):
    """
    Verifies the submitted OTP and issues JWT tokens.
    """

    def post(self, request):
        phone_number = request.data.get("phone_number")
        otp_code = request.data.get("otp_code")

        if not all([phone_number, otp_code]):
            return Response(
                {"error": "Phone number and OTP required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.filter(phone_number=phone_number).first()
        if not user:
            # Hide whether the user exists for security
            return Response(
                {"error": "Invalid OTP or phone number."},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        # Check for active lockout again (redundant but safe)
        if user.lockout_until and user.lockout_until > timezone.now():
            remaining_time = (user.lockout_until - timezone.now()).seconds // 60
            return Response(
                {"error": f"Account locked. Try again in {remaining_time} minutes."},
                status=status.HTTP_403_FORBIDDEN,
            )

        # 1. OTP Lookup and Validation
        otp_record = (
            OTP.objects.filter(phone_number=phone_number, code=otp_code, is_used=False)
            .order_by("-created_at")
            .first()
        )

        is_valid = otp_record is not None and not otp_record.is_expired()

        if is_valid:
            # --- SUCCESS PATH ---

            # 2. Mark OTP as used
            otp_record.is_used = True
            otp_record.save()

            # 3. Reset lockout counters
            user.failed_login_attempts = 0
            user.lockout_until = None
            user.save()

            # 4. Issue Tokens
            refresh = RefreshToken.for_user(user)
            return Response(
                {
                    "message": "Login successful.",
                    "access_token": str(refresh.access_token),
                    "refresh_token": str(refresh),
                },
                status=status.HTTP_200_OK,
            )
        else:
            # --- FAILURE PATH (Brute Force Handling) ---

            user.failed_login_attempts += 1

            if user.failed_login_attempts >= MAX_OTP_ATTEMPTS:
                # Lock the account
                user.lockout_until = timezone.now() + timedelta(
                    minutes=LOCKOUT_DURATION_MINUTES
                )
                user.failed_login_attempts = 0  # Reset count after locking
                user.save()

                # Notify user of lockout
                return Response(
                    {
                        "error": f"Maximum attempts reached. Account locked for {LOCKOUT_DURATION_MINUTES} minutes."
                    },
                    status=status.HTTP_403_FORBIDDEN,
                )
            else:
                user.save()
                attempts_left = MAX_OTP_ATTEMPTS - user.failed_login_attempts

                # Return generic error for security, but maybe hint attempts left
                return Response(
                    {"error": f"Invalid OTP. {attempts_left} attempts remaining."},
                    status=status.HTTP_401_UNAUTHORIZED,
                )
