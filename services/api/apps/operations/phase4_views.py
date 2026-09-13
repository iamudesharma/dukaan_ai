"""Phase 4 views: bill-media uploads and global search."""

from django.db.models import Q
from rest_framework.exceptions import ValidationError
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.catalog.models import Party, Product
from apps.tenancy.access import require_membership
from apps.tenancy.models import Membership

from .models import Attachment, Purchase, Sale
from .phase3_serializers import AttachmentSerializer

MAX_UPLOAD_BYTES = 10 * 1024 * 1024

MIME_TO_KIND = {
    "image/jpeg": Attachment.Kind.UPLOAD_PHOTO,
    "image/png": Attachment.Kind.UPLOAD_PHOTO,
    "image/webp": Attachment.Kind.UPLOAD_PHOTO,
    "application/pdf": Attachment.Kind.UPLOAD_PDF,
    "audio/mpeg": Attachment.Kind.UPLOAD_AUDIO,
    "audio/mp4": Attachment.Kind.UPLOAD_AUDIO,
    "audio/x-m4a": Attachment.Kind.UPLOAD_AUDIO,
    "audio/wav": Attachment.Kind.UPLOAD_AUDIO,
    "audio/x-wav": Attachment.Kind.UPLOAD_AUDIO,
    "audio/ogg": Attachment.Kind.UPLOAD_AUDIO,
    "audio/webm": Attachment.Kind.UPLOAD_AUDIO,
}


class AttachmentListCreateView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        business_id = request.query_params.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        require_membership(request.user, business_id)
        rows = Attachment.objects.filter(business_id=business_id).order_by("-created_at")[:100]
        return Response(AttachmentSerializer(rows, many=True).data)

    def post(self, request):
        business_id = request.data.get("business_id")
        if not business_id:
            raise ValidationError("business_id is required")
        require_membership(request.user, str(business_id))
        upload = request.FILES.get("file")
        if upload is None:
            raise ValidationError("Attach the bill as multipart field 'file'")
        if upload.size > MAX_UPLOAD_BYTES:
            raise ValidationError("Files must be at most 10 MB")
        mime_type = (upload.content_type or "").split(";")[0].strip().lower()
        kind = MIME_TO_KIND.get(mime_type)
        if kind is None:
            raise ValidationError(
                "Supported files: JPG/PNG/WebP photos, PDF bills, MP3/M4A/WAV audio"
            )
        from apps.tenancy.models import Business

        attachment = Attachment(
            business=Business.objects.get(pk=business_id),
            kind=kind,
            uploaded_by=request.user,
            original_name=(upload.name or "")[:255],
            mime_type=mime_type,
            size_bytes=upload.size,
            status=Attachment.Status.READY,
        )
        attachment.file.save(f"uploads/{attachment.pk}/{upload.name}", upload, save=False)
        attachment.save()
        return Response(AttachmentSerializer(attachment).data, status=201)


class AttachmentPresignView(APIView):
    """Dev presign: direct multipart upload instructions.

    Production Supabase private-storage signing plugs in here behind the
    same response shape; until bucket credentials exist the client uploads
    straight to ``upload_url``. The shape (mode/upload_url/key) is what
    clients code against.
    """

    def post(self, request):
        business_id = request.data.get("business_id")
        filename = str(request.data.get("filename") or "")
        mime_type = str(request.data.get("mime_type") or "").split(";")[0].strip().lower()
        if not business_id:
            raise ValidationError("business_id is required")
        require_membership(request.user, str(business_id))
        if not filename:
            raise ValidationError("filename is required")
        if mime_type not in MIME_TO_KIND:
            raise ValidationError(
                "Supported files: JPG/PNG/WebP photos, PDF bills, MP3/M4A/WAV audio"
            )
        return Response(
            {
                "mode": "direct",
                "upload_url": "/api/v1/attachments/",
                "key": f"uploads/{filename}",
                "max_size_bytes": MAX_UPLOAD_BYTES,
            }
        )


class SearchView(APIView):
    """Scoped global search over parties, products, and documents.

    Cashiers see sales, customers, and products only — supplier and purchase
    rows stay manager-visible, mirroring the report gating.
    """

    def get(self, request):
        business_id = request.query_params.get("business_id")
        query = (request.query_params.get("q") or "").strip()
        if not business_id:
            raise ValidationError("business_id is required")
        if len(query) < 2:
            raise ValidationError("Search for at least 2 characters")
        membership = require_membership(request.user, business_id)
        is_cashier = membership.role == Membership.Role.CASHIER
        requested = (request.query_params.get("types") or "").strip()
        wanted = (
            {part.strip() for part in requested.split(",") if part.strip()}
            if requested
            else {"parties", "products", "documents"}
        )
        unknown = wanted - {"parties", "products", "documents"}
        if unknown:
            raise ValidationError(f"Unknown search types: {', '.join(sorted(unknown))}")
        results: dict = {}
        if "parties" in wanted:
            parties = Party.objects.filter(business_id=business_id, is_active=True).filter(
                Q(name__icontains=query) | Q(phone_e164__icontains=query)
            )
            if is_cashier:
                parties = parties.exclude(kind=Party.Kind.SUPPLIER)
            results["parties"] = [
                {"id": str(party.pk), "name": party.name, "kind": party.kind}
                for party in parties.order_by("name")[:10]
            ]
        if "products" in wanted:
            products = Product.objects.filter(business_id=business_id, is_active=True).filter(
                Q(name__icontains=query) | Q(sku__icontains=query)
            )
            results["products"] = [
                {"id": str(product.pk), "name": product.name, "sku": product.sku}
                for product in products.order_by("name")[:10]
            ]
        if "documents" in wanted:
            sales = (
                Sale.objects.filter(business_id=business_id)
                .filter(Q(number__icontains=query) | Q(buyer_name__icontains=query))
                .order_by("-document_date")[:10]
            )
            documents = [
                {
                    "id": str(sale.pk),
                    "kind": "SALE",
                    "number": sale.number,
                    "party": sale.buyer_name,
                    "total_minor": sale.grand_total_minor,
                }
                for sale in sales
            ]
            if not is_cashier:
                purchases = (
                    Purchase.objects.filter(business_id=business_id)
                    .filter(Q(number__icontains=query) | Q(seller_name__icontains=query))
                    .order_by("-document_date")[:10]
                )
                documents.extend(
                    {
                        "id": str(purchase.pk),
                        "kind": "PURCHASE",
                        "number": purchase.number,
                        "party": purchase.seller_name,
                        "total_minor": purchase.grand_total_minor,
                    }
                    for purchase in purchases
                )
            results["documents"] = documents
        return Response({"query": query, "results": results})
