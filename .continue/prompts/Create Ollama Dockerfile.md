---
name: Ollama Dockerfile creation
description: Create a Dockerfile for Ollama deployment
invokable: true
---

Create a Dockerfile for deploying an Ollama service.
The dockerfile has to be created in /Runpod/Dockerfile.  
If already exists, copy the current into Runpod/Dockerfile.bak (overwrite) before overwriting.
The dockerfile has to use the base image ollama/ollama and install any dependencies needed for the model to run.
Runpod set the /root/.ollama directory as volume, so that directory can be used to persist data.
The dockerfile has to add a NGINX server that serves the ollama api on port 11434.
The dockerfile has to expose port 11434.
NGINX has to be configured to run as reverse proxy for the ollama api.
The dockerfile has to start the ollama api and the NGINX server.  
The NGINX has to be configured to protect the ollama api with API_KEY passed has HTTP header.

One possibility is like the idea exposed here:
  
```
/etc/nginx/sites-available/ollama:

map \$http_authorization \$api_key_valid {
    default 0;
    "Bearer ${API_KEY}" 1;
}

server {
    listen 80;
    location / {
        if (\$api_key_valid = 0) {
            return 401 "Unauthorized";
        }
        proxy_pass http://127.0.0.1:11434;
    }
}


ln -sf /etc/nginx/sites-available/ollama /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
```
