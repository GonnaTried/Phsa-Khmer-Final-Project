import uuid
from datetime import timedelta

from django.conf import settings
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models
from django.utils import timezone

# Get the expiry time from settings, defaulting to 2 minutes
CODE_EXPIRY_MINUTES = getattr(settings, "TELEGRAM_CODE_EXPIRY_MINUTES", 2)


class CustomUser(AbstractUser):
    """
    Custom User Model storing essential e-commerce and Telegram verification data.
    """

    # --- Overridden M2M fields (Required when using AbstractUser) ---
    groups = models.ManyToManyField(
        Group,
        related_name="custom_user_groups",
        blank=True,
        help_text="The groups this user belongs to.",
        related_query_name="custom_user",
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name="custom_user_permissions",
        blank=True,
        help_text="Specific permissions for this user.",
        related_query_name="custom_user",
    )
    # ----------------------------------------------------------------------
    # --- Brute Force Protection Fields ---
    failed_login_attempts = models.IntegerField(default=0)
    lockout_until = models.DateTimeField(null=True, blank=True)

    # --- Custom Fields for E-commerce and Telegram Auth ---

    phone_number = models.CharField(max_length=15, unique=True, blank=True, null=True)

    telegram_chat_id = models.CharField(
        max_length=50, unique=True, blank=True, null=True
    )

    telegram_username = models.CharField(
        max_length=150, unique=False, blank=True, null=True
    )
    telegram_first_name = models.CharField(max_length=255, blank=True, null=True)
    telegram_last_name = models.CharField(max_length=255, blank=True, null=True)

    telegram_profile_link = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"

    def __str__(self):
        return self.username


STATE_TYPE_REGISTRATION = "REG"
STATE_TYPE_LOGIN = "LOG"

STATE_CHOICES = [
    (STATE_TYPE_REGISTRATION, "Registration"),
    (STATE_TYPE_LOGIN, "Login"),
]


class TelegramRegistrationState(models.Model):
    """
    Tracks the temporary state of a user attempting to register via Telegram
    until the FinalRegistrationView is called.
    """

    one_time_code = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)

    telegram_chat_id = models.CharField(
        max_length=50, blank=True, null=True, unique=True, db_index=True
    )

    state_type = models.CharField(
        max_length=3,
        choices=STATE_CHOICES,
        default=STATE_TYPE_REGISTRATION,
    )

    telegram_username = models.CharField(max_length=255, blank=True, null=True)
    telegram_first_name = models.CharField(max_length=255, blank=True, null=True)
    telegram_last_name = models.CharField(max_length=255, blank=True, null=True)

    is_verified = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Telegram Registration State"
        verbose_name_plural = "Telegram Registration States"

    def is_expired(self):
        """Checks if the registration window has passed."""
        return timezone.now() > self.created_at + timedelta(minutes=CODE_EXPIRY_MINUTES)

    def __str__(self):
        return f"State: {self.one_time_code} (Verified: {self.is_verified})"


class OTP(models.Model):
    phone_number = models.CharField(max_length=15, db_index=True)
    code = models.CharField(max_length=6)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="otps",
        null=True,
        blank=True,
    )

    def is_expired(self):
        return self.expires_at < timezone.now()

    def __str__(self):
        return f"OTP for {self.phone_number}"


class OTP(models.Model):
    phone_number = models.CharField(max_length=15, db_index=True)
    code = models.CharField(max_length=6)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="otps",
        null=True,
        blank=True,
    )

    def is_expired(self):
        return self.expires_at < timezone.now()

    def __str__(self):
        return f"OTP for {self.phone_number}"
