<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="FruitBazar - Fresh Fruits Delivered To Your Door" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="hero">
    <div class="hero-text">
        <h1>Fresh Fruits, Delivered Fast.</h1>
        <p>Hand-picked, farm-fresh fruits delivered to your doorstep the same day. No middlemen, no compromise on quality.</p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/fruits.jsp">Shop Fruits</a>
    </div>
    <div class="hero-image">
        <img src="${pageContext.request.contextPath}/images/hero-basket.png" alt="Fresh fruit basket">
    </div>
</section>

<section class="highlights">
    <div class="container grid-3">
        <div class="highlight-card">
            <span class="icon">🚚</span>
            <h3>Same-Day Delivery</h3>
            <p>Order before 5 PM and get your fruits delivered the same evening.</p>
        </div>
        <div class="highlight-card">
            <span class="icon">🌿</span>
            <h3>Farm Fresh Quality</h3>
            <p>Sourced directly from trusted local farms, picked at peak ripeness.</p>
        </div>
        <div class="highlight-card">
            <span class="icon">💳</span>
            <h3>Easy Checkout</h3>
            <p>Simple cart and checkout flow — order in under a minute.</p>
        </div>
    </div>
</section>

<section class="featured-fruits">
    <div class="container">
        <h2>All Our Fruits</h2>
        <div class="grid grid-4">
            <c:forEach var="fruit" items="${fruitCatalog}">
                <div class="card">
                    <img class="card-img" src="${pageContext.request.contextPath}/${fruit.imageUrl}" alt="${fruit.name}">
                    <h3><c:out value="${fruit.name}" /></h3>
                    <p class="price">₹<c:out value="${fruit.price}" /> <span><c:out value="${fruit.unit}" /></span></p>
                    <form action="${pageContext.request.contextPath}/addToCart" method="post">
                        <input type="hidden" name="fruitId" value="${fruit.id}">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-secondary">Add to Cart</button>
                    </form>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<section class="testimonials">
    <div class="container">
        <h2>What Our Customers Say</h2>
        <div class="grid grid-3">
            <blockquote>"Fruits arrive so fresh, tastes like they were just picked!" &mdash; Ananya R.</blockquote>
            <blockquote>"Fast delivery and great packaging. My go-to for weekly fruit orders." &mdash; Karthik M.</blockquote>
            <blockquote>"Love the variety — found exotic fruits I couldn't get elsewhere." &mdash; Priya S.</blockquote>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
