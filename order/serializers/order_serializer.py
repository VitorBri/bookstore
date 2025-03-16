from rest_framework import serializers

from order.models import Order
from product.models import Product
from product.serializers.product_serializer import ProductSerializer


class OrderSerializer(serializers.ModelSerializer):
    product = ProductSerializer(required=False, many=True, read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(queryset=Product.objects.all(), write_only=True, many=True)
    total = serializers.SerializerMethodField()

    def get_total(self, instance):
        total = sum([product.price for product in instance.product.all()])
        return total

    class Meta:
        model = Order
        fields = ['product', 'total','user','product_id']
        extra_kwargs = {'product':{'required':False}}

    def create(self, validated_data):
        product_data = validated_data.pop("product_id")
        user = validated_data.pop('user')

        order = Order.objects.create(user=user)
        for product in product_data:
            order.product.add(product)

        return order