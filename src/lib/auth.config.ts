import type { NextAuthConfig } from "next-auth";

// Auth configuration that doesn't require database access
// Used by middleware which runs in Edge Runtime
export const authConfig: NextAuthConfig = {
  pages: {
    signIn: "/login",
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
      }
      return session;
    },
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user;
      const pathname = nextUrl.pathname;

      // Public routes that don't require authentication
      const publicRoutes = [
        "/login",
        "/register",
        "/api/auth",
        "/pay",
        "/api/pay",
        "/api/webhooks",
      ];

      const isPublicRoute = publicRoutes.some(
        (route) => pathname === route || pathname.startsWith(route + "/")
      );

      if (isPublicRoute) {
        return true;
      }

      // Redirect to login if not authenticated
      if (!isLoggedIn) {
        return false;
      }

      return true;
    },
  },
  session: {
    strategy: "jwt",
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
  secret: process.env.NEXTAUTH_SECRET,
  providers: [], // Providers are added in auth.ts
};
