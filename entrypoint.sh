#!/bin/sh
set -e

# 1. Check for API_KEY environment variable
if [ -z "$API_KEY" ]; then
  echo "Error: API_KEY environment variable is not set."
  exit 1
fi

# 2. Create NGINX config to validate the standard 'Authorization: Bearer' header
cat > /etc/nginx/sites-available/ollama << EOF
# This map block creates a variable \$api_key_valid based on the "Authorization" header
map \$http_authorization \$api_key_valid {
    default 0;
    "Bearer ${API_KEY}" 1;
}

server {
    # NGINX will listen on port 80 within the container
    listen 80;
    server_name _;

    location / {
        # If the API key is not valid, return a 401 Unauthorized error
        if (\$api_key_valid = 0) {
            return 401 "Unauthorized";
        }

        # proxy the request to the Ollama service running on port 11434
        proxy_pass http://127.0.0.1:11434;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 3. Enable the new NGINX site and remove the default one
ln -sf /etc/nginx/sites-available/ollama /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 4. Start the Ollama service in the background
/bin/ollama serve &

# 5. Start NGINX in the foreground
nginx -g 'daemon off;'
