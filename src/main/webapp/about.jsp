<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="About Us - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="page-banner">
    <div class="container">
        <h1>About FruitBazar</h1>
        <p>Bringing farm-fresh fruit straight to your door since day one.</p>
    </div>
</section>

<section class="about-content">
    <div class="container about-grid">
        <div class="about-text">
            <h2>Our Story</h2>
            <p>FruitBazar started with a simple idea: everyone deserves access to truly fresh fruit, without
               the hassle of markets, middlemen, or guesswork about quality. We partner directly with local
               orchards and farms, so every mango, apple, or box of berries you receive was picked at
               peak ripeness — not weeks before it reached a shelf.</p>
            <p>Today we deliver thousands of orders every week across the city, with a promise that hasn't
               changed since we started: fresh fruit, fair prices, and fast delivery.</p>
        </div>
        <div class="about-image">
            <img src="https://picsum.photos/seed/fruitbazar-orchard/600/450" alt="Fruit orchard">
        </div>
    </div>

    <div class="container grid-3 values">
        <div class="highlight-card">
            <span class="icon">🌱</span>
            <h3>Sustainably Sourced</h3>
            <p>We work with farms that use sustainable growing practices and fair labor.</p>
        </div>
        <div class="highlight-card">
            <span class="icon">❄️</span>
            <h3>Cold-Chain Delivery</h3>
            <p>Temperature-controlled logistics keep every fruit fresh from farm to door.</p>
        </div>
        <div class="highlight-card">
            <span class="icon">🤝</span>
            <h3>Community First</h3>
            <p>A share of every order supports local farming communities.</p>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
