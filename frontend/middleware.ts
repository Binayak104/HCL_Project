import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
    if (request.nextUrl.pathname.startsWith('/api/')) {
        // Use API_BASE_URL (runtime only) instead of NEXT_PUBLIC_API_URL (baked at build time)
        const apiUrl = process.env.API_BASE_URL;

        if (!apiUrl) {
            console.error("Middleware: API_BASE_URL is missing");
            return new NextResponse(
                JSON.stringify({ error: 'Configuration Error: API_BASE_URL missing' }),
                { status: 500, headers: { 'content-type': 'application/json' } }
            );
        }

        // Construct the destination URL
        // Remove /api prefix and append the rest of the path
        const path = request.nextUrl.pathname.replace(/^\/api/, '');
        const search = request.nextUrl.search;
        const destUrl = `${apiUrl}${path}${search}`;

        console.log(`Middleware Proxy: ${request.nextUrl.pathname} -> ${destUrl}`);

        return NextResponse.rewrite(new URL(destUrl));
    }
}

export const config = {
    matcher: '/api/:path*',
}
