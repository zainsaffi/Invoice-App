import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import { queryOne, UserRow, toUser } from "@/db";
import bcrypt from "bcryptjs";
import { authConfig } from "./auth.config";

export const { handlers, signIn, signOut, auth } = NextAuth({
  ...authConfig,
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }

        const userRow = await queryOne<UserRow>(
          "SELECT * FROM users WHERE email = $1",
          [credentials.email as string]
        );

        if (!userRow) {
          return null;
        }

        const user = toUser(userRow);

        const isPasswordValid = await bcrypt.compare(
          credentials.password as string,
          user.password
        );

        if (!isPasswordValid) {
          return null;
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
        };
      },
    }),
  ],
});

// Helper to get authenticated user in API routes
export async function getAuthenticatedUser() {
  const session = await auth();
  if (!session?.user?.id) {
    return null;
  }
  return session.user;
}

// Helper to require authentication in API routes
export async function requireAuth() {
  const user = await getAuthenticatedUser();
  if (!user) {
    throw new Error("Unauthorized");
  }
  return user;
}
