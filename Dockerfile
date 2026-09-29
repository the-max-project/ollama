# Ollama Docker file
# Copies from the official ollama/ollama base image to base ubuntu to have ollama run as non-root user

# Stage 1: Pull the officially tested and verified Ollama binaries
FROM ollama/ollama:latest AS ollama_source

# Stage 2: Build a clean, ultra-lightweight, secure target image
# Ubuntu 24.04 is the current base version used by Ollama
FROM ubuntu:24.04

ARG OLLAMA_DEBUG=0

# Re-apply your target environment variables
ENV OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/home/ollama/.ollama \
    OLLAMA_MAX_LOADED_MODELS=1 \
    OLLAMA_DEBUG=$OLLAMA_DEBUG

# 1. Install SSL certificates so Ollama can download models
# 2. Cleanly rename the default user to match your UID 1000 permissions
# 3. Rename the existing group 'ubuntu' to 'ollama'
# 4. Rename the user 'ubuntu' to 'ollama' and change its home directory path
# 5. Create the models directory and fix all file permissions
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/* && \
    groupmod -n ollama ubuntu && \
    usermod -l ollama -d /home/ollama -m ubuntu && \
    mkdir -p ${OLLAMA_MODELS} && \
    chown -R ollama:ollama /home/ollama

# Extract EVERYTHING required for GPU execution from the official source image layer
COPY --from=ollama_source /bin/ollama /bin/ollama
COPY --from=ollama_source /usr/lib/ollama /usr/lib/ollama

# Switch to the secure non-root context
USER ollama

EXPOSE 11434

ENTRYPOINT [ "ollama", "serve" ]
