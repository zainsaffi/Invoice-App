module.exports = {
  apps: [
    {
      name: 'invoice-app',
      script: 'node_modules/.bin/next',
      args: 'dev -p 3005',
      cwd: '/Users/jordanhardison/JAH Dropbox/Jordan Hardison/12 - Development Company/Invoicing/Invoice-App',
      env: {
        NODE_ENV: 'development',
      },
      env_production: {
        NODE_ENV: 'production',
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '1G',
    },
  ],
};
