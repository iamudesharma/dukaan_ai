import re

from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

User = get_user_model()

PHONE_REGEX = re.compile(r"^\+[1-9]\d{6,14}$")


class SignupSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True, min_length=8)
    display_name = serializers.CharField(max_length=120, required=False, allow_blank=True)

    def validate_phone(self, value: str) -> str:
        normalized = re.sub(r"[\s()-]", "", value)
        if not PHONE_REGEX.match(normalized):
            raise serializers.ValidationError(
                "Enter a valid phone number with country code, e.g. +919876543210."
            )
        if User.objects.filter(phone_e164=normalized, is_active=True).exists():
            raise serializers.ValidationError("An account with this phone number already exists.")
        return normalized

    def validate_password(self, value: str) -> str:
        validate_password(value)
        return value

    def create(self, validated_data: dict) -> User:
        return User.objects.create_user(
            username=f"phone_{validated_data['phone']}",
            phone_e164=validated_data["phone"],
            password=validated_data["password"],
            display_name=validated_data.get("display_name", ""),
        )


class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)

    def validate_phone(self, value: str) -> str:
        return re.sub(r"[\s()-]", "", value)

    def validate(self, attrs: dict) -> dict:
        user = authenticate(username=f"phone_{attrs['phone']}", password=attrs["password"])
        if not user:
            raise serializers.ValidationError(
                "Invalid phone number or password.", "invalid_credentials"
            )
        if not user.is_active:
            raise serializers.ValidationError("This account has been disabled.", "account_disabled")
        attrs["user"] = user
        return attrs


class OtpSendSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)

    def validate_phone(self, value: str) -> str:
        normalized = re.sub(r"[\s()-]", "", value)
        if not PHONE_REGEX.match(normalized):
            raise serializers.ValidationError(
                "Enter a valid phone number with country code, e.g. +919876543210."
            )
        return normalized


class OtpVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    otp = serializers.CharField(min_length=4, max_length=8)

    def validate_phone(self, value: str) -> str:
        return re.sub(r"[\s()-]", "", value)

    def validate_otp(self, value: str) -> str:
        return value.strip()


class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_new_password(self, value: str) -> str:
        validate_password(value)
        return value

    def validate(self, attrs: dict) -> dict:
        user = self.context["request"].user
        if not user.check_password(attrs["old_password"]):
            raise serializers.ValidationError("Current password is incorrect.", "invalid_password")
        return attrs


class PasswordResetRequestSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)

    def validate_phone(self, value: str) -> str:
        normalized = re.sub(r"[\s()-]", "", value)
        if not PHONE_REGEX.match(normalized):
            raise serializers.ValidationError(
                "Enter a valid phone number with country code, e.g. +919876543210."
            )
        return normalized


class PasswordResetConfirmSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    otp = serializers.CharField(min_length=4, max_length=8)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_phone(self, value: str) -> str:
        return re.sub(r"[\s()-]", "", value)

    def validate_new_password(self, value: str) -> str:
        validate_password(value)
        return value
