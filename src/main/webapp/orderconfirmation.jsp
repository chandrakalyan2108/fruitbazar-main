<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Order Confirmed - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="page-banner">
    <div class="container">
        <h1>Thank You, <c:out value="${customerName}" />! 🎉</h1>
        <p>Your order has been placed successfully.</p>
    </div>
</section>

<section class="confirmation-section">
    <div class="container confirmation-card">
        <p><strong>Order ID:</strong> <c:out value="${orderId}" /></p>
        <p><strong>Deliver to:</strong> <c:out value="${address}" /></p>
        <p><strong>Phone:</strong> <c:out value="${phone}" /></p>

        <ul class="summary-list">
            <c:forEach var="item" items="${items}">
                <li>
                    <span><c:out value="${item.fruit.name}" /> &times; <c:out value="${item.quantity}" /></span>
                    <span>₹<fmt:formatNumber value="${item.subtotal}" maxFractionDigits="2" /></span>
                </li>
            </c:forEach>
        </ul>
        <p class="cart-total">Total Paid: ₹<fmt:formatNumber value="${total}" maxFractionDigits="2" /></p>

        <a class="btn btn-primary" href="${pageContext.request.contextPath}/fruits.jsp">Continue Shopping</a>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
