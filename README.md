# FruitBazar — Fruit Delivery Website

A Maven-based Java web application (WAR) on Tomcat 9, deployed to AWS ECS Fargate with Terraform.

## Stack
- Java 21, Servlet API 4.0 (annotations, no servlet XML mappings needed)
- JSP + JSTL for views
- Maven (`maven-war-plugin`) for packaging
- Session-based shopping cart
- MySQL (Amazon RDS) for users and orders
- Docker image on Amazon ECR, running on ECS Fargate behind an ALB
- Terraform for all infrastructure, GitHub Actions for CI/CD, domain on Hostinger

**Deploying: see [DEPLOYMENT.md](DEPLOYMENT.md).**

## Pages
| Page | File |
|---|---|
| Home | `index.jsp` |
| About Us | `about.jsp` |
| Fruits / Gallery | `fruits.jsp` |
| Cart | `cart.jsp` |
| Checkout | `checkout.jsp` + `orderconfirmation.jsp` |
| Login | `login.jsp` |
| FAQ | `faq.jsp` |
| Error | `error.jsp` |

## Demo login
```
username: demo
password: demo123
```
(Seeded into MySQL with a PBKDF2 hash on startup; in-memory fallback when no DB is configured.)

## Local build
```bash
mvn clean package
```
This produces `target/FruitBazar.war`.

## Run locally with Docker
```bash
docker build -t fruitbazar .
docker run -p 8080:8080 fruitbazar     # http://localhost:8080 (in-memory mode, no DB)
```

## Images
Fruit photos load via `picsum.photos` with fixed per-fruit seeds (deterministic, so the
same fruit always shows the same photo). This is the same image service already proven
reliable on your event management site. It is not Flickr-backed, so it avoids the slow/
blocked-image issue that `loremflickr.com` can have on some networks.

If you want literal photos of each specific fruit (not just a styled placeholder), replace
the `imageUrl` values in `FruitCatalog.java` with your own hosted image URLs, or drop image
files into `src/main/webapp/images/` and reference them as
`${pageContext.request.contextPath}/images/mango.jpg`.

## Notes / next steps
- Users and orders are stored in MySQL on AWS; the cart stays in the HTTP session.
- No payment gateway is wired up; checkout currently just records the order and clears the cart.
