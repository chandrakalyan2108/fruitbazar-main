<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    java.util.Map cart = (java.util.Map) session.getAttribute("cart");
    int cartCount = 0;
    if (cart != null) {
        java.util.Iterator it = cart.values().iterator();
        while (it.hasNext()) {
            Object item = it.next();
            cartCount += ((com.fruitbazar.model.CartItem) item).getQuantity();
        }
    }
    request.setAttribute("cartCount", cartCount);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle != null ? pageTitle : 'FruitBazar - Fresh Fruits Delivered'}" /></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<header class="site-header">
    <div class="container nav-wrap">
        <a class="brand" href="${pageContext.request.contextPath}/">🍉 FruitBazar</a>
        <nav>
            <a href="${pageContext.request.contextPath}/">Home</a>
            <a href="${pageContext.request.contextPath}/about.jsp">About Us</a>
            <a href="${pageContext.request.contextPath}/fruits.jsp">Fruits</a>
            <a href="${pageContext.request.contextPath}/faq.jsp">FAQ</a>
            <a class="cart-link" href="${pageContext.request.contextPath}/cart.jsp">
                🛒 Cart
                <c:if test="${cartCount > 0}">
                    <span class="cart-badge"><c:out value="${cartCount}" /></span>
                </c:if>
            </a>
            <c:choose>
                <c:when test="${sessionScope.user != null}">
                    <span class="hello-user">Hi, <c:out value="${sessionScope.user.fullName}" /></span>
                    <a href="${pageContext.request.contextPath}/logout">Logout</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login.jsp">Login</a>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</header>
<main>
