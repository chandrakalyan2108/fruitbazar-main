package com.fruitbazar.servlet;

import com.fruitbazar.data.FruitCatalog;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

/**
 * Makes the fruit catalog available as a request attribute on every request,
 * so JSPs can render it via JSTL without needing a dedicated servlet per page.
 */
@WebFilter("/*")
public class CatalogFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setAttribute("fruitCatalog", FruitCatalog.getAll());
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
