# Base image
FROM ollama/ollama

# Install NGINX and clean up apt cache
RUN apt-get update && apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the port NGINX will listen on
EXPOSE 80

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


