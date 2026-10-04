<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Checkout - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<%
    java.util.Map cart = (java.util.Map) session.getAttribute("cart");
    boolean cartEmpty = (cart == null || cart.isEmpty());
    request.setAttribute("cartEmpty", cartEmpty);
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
        <h1>Checkout</h1>
    </div>
</section>

<section class="checkout-section">
    <div class="container">
        <c:choose>
            <c:when test="${sessionScope.user == null}">
                <div class="empty-state">
                    <p>Please log in to continue with checkout.</p>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/login.jsp">Login</a>
                </div>
            </c:when>
            <c:when test="${cartEmpty}">
                <div class="empty-state">
                    <p>Your cart is empty.</p>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/fruits.jsp">Shop Fruits</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="checkout-grid">
                    <form action="${pageContext.request.contextPath}/checkout" method="post" class="checkout-form">
                        <h2>Delivery Details</h2>
                        <c:if test="${not empty error}">
                            <p class="error-msg"><c:out value="${error}" /></p>
                        </c:if>
                        <label>Full Name
                            <input type="text" name="fullName" value="${sessionScope.user.fullName}" required>
                        </label>
                        <label>Delivery Address
                            <textarea name="address" rows="3" required></textarea>
                        </label>
                        <label>Phone Number
                            <input type="tel" name="phone" required>
                        </label>
                        <button type="submit" class="btn btn-primary btn-full">Place Order</button>
                    </form>

                    <div class="order-summary">
                        <h2>Order Summary</h2>
                        <ul class="summary-list">
                            <c:forEach var="item" items="${cartItems}">
                                <li>
                                    <span><c:out value="${item.fruit.name}" /> &times; <c:out value="${item.quantity}" /></span>
                                    <span>₹<fmt:formatNumber value="${item.subtotal}" maxFractionDigits="2" /></span>
                                </li>
                            </c:forEach>
                        </ul>
                        <p class="cart-total">Total: ₹<fmt:formatNumber value="${cartTotal}" maxFractionDigits="2" /></p>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
