module.exports = {
    output: 'export', // static export for offline use
    images: { unoptimized: true },
    async headers() {
        return [
            {
                source: '/(.*)',
                headers: [
                    { key: 'X-Content-Type-Options', value: 'nosniff' },
                    { key: 'X-Frame-Options', value: 'DENY' },
                    // Onion-Location header for Tor hidden service detection
                    { key: 'Onion-Location', value: 'http://yourhiddenservice.onion' },
                ],
            },
        ];
    },
};
