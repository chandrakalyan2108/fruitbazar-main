<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Something Went Wrong - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="page-banner">
    <div class="container">
        <h1>Oops! Something went wrong.</h1>
        <p>The page you're looking for doesn't exist or an error occurred.</p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/">Back to Home</a>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
