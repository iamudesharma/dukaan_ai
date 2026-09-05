from django.contrib import admin

from .models import Party, Product, ProductPack

admin.site.register([Party, Product, ProductPack])
