// FruitBazar front-end enhancements
document.addEventListener('DOMContentLoaded', function () {
    // Confirm before removing an item from the cart
    document.querySelectorAll('.remove-link').forEach(function (link) {
        link.addEventListener('click', function (e) {
            if (!confirm('Remove this item from your cart?')) {
                e.preventDefault();
            }
        });
    });
});
