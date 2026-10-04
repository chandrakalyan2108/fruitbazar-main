<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Shop Fruits - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="page-banner">
    <div class="container">
        <h1>Fresh Fruits</h1>
        <p>Browse our full range of hand-picked, farm-fresh fruits.</p>
    </div>
</section>

<section class="fruit-gallery">
    <div class="container">
        <div class="grid grid-4">
            <c:forEach var="fruit" items="${fruitCatalog}">
                <div class="card">
                    <img class="card-img" src="${pageContext.request.contextPath}/${fruit.imageUrl}" alt="${fruit.name}">
                    <span class="tag"><c:out value="${fruit.category}" /></span>
                    <h3><c:out value="${fruit.name}" /></h3>
                    <p class="desc"><c:out value="${fruit.description}" /></p>
                    <p class="price">₹<c:out value="${fruit.price}" /> <span><c:out value="${fruit.unit}" /></span></p>
                    <form action="${pageContext.request.contextPath}/addToCart" method="post" class="add-form">
                        <input type="hidden" name="fruitId" value="${fruit.id}">
                        <input type="number" name="quantity" value="1" min="1" class="qty-input">
                        <button type="submit" class="btn btn-secondary">Add to Cart</button>
                    </form>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
