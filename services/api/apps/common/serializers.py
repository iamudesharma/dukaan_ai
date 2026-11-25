"""Response serializers for endpoints whose payload is assembled directly in views."""

from rest_framework import serializers

from apps.tenancy.models import Membership


class HealthSerializer(serializers.Serializer):
    status = serializers.CharField()


class MembershipSummarySerializer(serializers.Serializer):
    business_id = serializers.UUIDField()
    business_name = serializers.CharField()
    role = serializers.ChoiceField(choices=Membership.Role.choices)


class MeSerializer(serializers.Serializer):
    id = serializers.UUIDField()
    phone = serializers.CharField(allow_blank=True)
    display_name = serializers.CharField(allow_blank=True)
    memberships = MembershipSummarySerializer(many=True)


class BootstrapUserSerializer(serializers.Serializer):
    id = serializers.UUIDField()
    name = serializers.CharField()
    phone = serializers.CharField(allow_blank=True)
    role = serializers.ChoiceField(choices=Membership.Role.choices)


class BootstrapBusinessSerializer(serializers.Serializer):
    id = serializers.UUIDField()
    name = serializers.CharField()
    legal_name = serializers.CharField(allow_blank=True)
    currency = serializers.CharField()
    timezone = serializers.CharField()


class BootstrapLocationSerializer(serializers.Serializer):
    id = serializers.UUIDField()
    name = serializers.CharField()
    code = serializers.CharField()
    state_code = serializers.CharField(allow_blank=True)


class BootstrapSerializer(serializers.Serializer):
    user = BootstrapUserSerializer()
    business = BootstrapBusinessSerializer()
    locations = BootstrapLocationSerializer(many=True)
    permissions = serializers.ListField(child=serializers.CharField())
