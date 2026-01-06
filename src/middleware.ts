import { auth } from "@/lib/auth";
import { NextResponse } from "next/server";

// Routes that don't require authentication
const publicRoutes = [
  "/login",
  "/register",
  "/api/auth",
  "/pay",           // Public payment pages
  "/api/pay",       // Public payment API
  "/api/webhooks",  // Stripe webhooks
];

export default auth((req) => {
  const { pathname } = req.nextUrl;

  // Check if the route is public
  const isPublicRoute = publicRoutes.some(
    (route) => pathname === route || pathname.startsWith(route + "/")
  );

  // If it's a public route, allow access
  if (isPublicRoute) {
    return NextResponse.next();
  }

  // Check if user is authenticated
  if (!req.auth) {
    // Redirect to login for protected routes
    const loginUrl = new URL("/login", req.url);
    loginUrl.searchParams.set("callbackUrl", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
});

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
