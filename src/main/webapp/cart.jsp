<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Your Cart - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<%
    java.util.Map cart = (java.util.Map) session.getAttribute("cart");
    request.setAttribute("cartItems", cart != null ? cart.values() : java.util.Collections.emptyList());
    double total = 0;
    if (cart != null) {
        java.util.Iterator it = cart.values().iterator();
        while (it.hasNext()) {
            total += ((com.fruitbazar.model.CartItem) it.next()).getSubtotal();
        }
    }
    request.setAttribute("cartTotal", total);
%>

<section class="page-banner">
    <div class="container">
        <h1>Your Cart</h1>
    </div>
</section>

<section class="cart-section">
    <div class="container">
        <c:choose>
            <c:when test="${empty cartItems}">
                <div class="empty-state">
                    <p>Your cart is empty.</p>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/fruits.jsp">Shop Fruits</a>
                </div>
            </c:when>
            <c:otherwise>
                <table class="cart-table">
                    <thead>
                        <tr>
                            <th>Fruit</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Subtotal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${cartItems}">
                            <tr>
                                <td class="cart-fruit">
                                    <img src="${pageContext.request.contextPath}/${item.fruit.imageUrl}" alt="${item.fruit.name}">
                                    <span><c:out value="${item.fruit.name}" /></span>
                                </td>
                                <td>₹<c:out value="${item.fruit.price}" /> <small><c:out value="${item.fruit.unit}" /></small></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/updateCart" method="post" class="qty-form">
                                        <input type="hidden" name="fruitId" value="${item.fruit.id}">
                                        <input type="number" name="quantity" value="${item.quantity}" min="0" class="qty-input">
                                        <button type="submit" class="btn btn-small">Update</button>
                                    </form>
                                </td>
                                <td>₹<fmt:formatNumber value="${item.subtotal}" maxFractionDigits="2" /></td>
                                <td>
                                    <a class="remove-link" href="${pageContext.request.contextPath}/removeFromCart?fruitId=${item.fruit.id}">Remove</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div class="cart-summary">
                    <p class="cart-total">Total: ₹<fmt:formatNumber value="${cartTotal}" maxFractionDigits="2" /></p>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/checkout.jsp">Proceed to Checkout</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
