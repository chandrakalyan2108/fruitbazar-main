<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Login - FruitBazar" scope="request"/>
<jsp:include page="/WEB-INF/includes/header.jsp" />

<section class="auth-section">
    <div class="container auth-box">
        <h1>Login</h1>
        <c:if test="${not empty error}">
            <p class="error-msg"><c:out value="${error}" /></p>
        </c:if>
        <form action="${pageContext.request.contextPath}/login" method="post" class="auth-form">
            <label>Username
                <input type="text" name="username" required>
            </label>
            <label>Password
                <input type="password" name="password" required>
            </label>
            <button type="submit" class="btn btn-primary btn-full">Login</button>
        </form>
        <p class="hint">Demo credentials: <strong>demo</strong> / <strong>demo123</strong></p>
    </div>
</section>

<jsp:include page="/WEB-INF/includes/footer.jsp" />
