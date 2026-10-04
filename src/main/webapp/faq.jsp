<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="FAQ - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="page-banner">
    <div class="container">
        <h1>Frequently Asked Questions</h1>
    </div>
</section>

<section class="faq-section">
    <div class="container faq-list">
        <div class="faq-item">
            <h3>What areas do you deliver to?</h3>
            <p>We currently deliver across Hyderabad and surrounding areas, with same-day delivery for orders
               placed before 5 PM.</p>
        </div>
        <div class="faq-item">
            <h3>How is freshness guaranteed?</h3>
            <p>All fruit is sourced directly from partner farms within 24-48 hours of harvest and moved through
               a cold chain until it reaches your door.</p>
        </div>
        <div class="faq-item">
            <h3>What payment methods are accepted?</h3>
            <p>We support cash on delivery, UPI, and major debit/credit cards at checkout.</p>
        </div>
        <div class="faq-item">
            <h3>Can I return a fruit if I'm not satisfied?</h3>
            <p>Yes — if any item doesn't meet our freshness promise, contact us within 24 hours of delivery for
               a replacement or refund.</p>
        </div>
        <div class="faq-item">
            <h3>Do you offer subscriptions?</h3>
            <p>Weekly and monthly fruit box subscriptions are coming soon. Sign up to our newsletter to be
               notified when they launch.</p>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
