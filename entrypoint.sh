#!/bin/bash
set -e

# 1. Check for API_KEY
if [ -z "$API_KEY" ]; then
  echo "Error: API_KEY environment variable is not set."
  exit 1
fi

# 2. Create NGINX config
cat > /etc/nginx/sites-available/ollama << EOF
map \$http_authorization \$api_key_valid {
    default 0;
    "Bearer ${API_KEY}" 1;
}

server {
    listen 80;
    server_name _;

    location / {
        if (\$api_key_valid = 0) {
            return 401 "Unauthorized";
        }

        proxy_pass http://127.0.0.1:11434;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 3. Enable the NGINX site
ln -sf /etc/nginx/sites-available/ollama /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 4. Start Ollama in the background
ollama serve &

# 5. Start NGINX in the foreground
nginx -g 'daemon off;'
