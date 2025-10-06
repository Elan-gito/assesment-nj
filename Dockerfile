# -------------------------------------------------------------------
# STAGE 1: Build Stage (Installs all dependencies)
# -------------------------------------------------------------------
    FROM node:20-slim AS builder

    WORKDIR /usr/src/app
    
    # Copy package files and install dependencies
    # This layer is cached well unless package.json changes
    COPY package*.json ./
    RUN npm install --omit=dev
    
    # -------------------------------------------------------------------
    # STAGE 2: Production Stage (Minimal image for security)
    # -------------------------------------------------------------------
    FROM node:20-slim AS final
    
    # Set up non-root user for security best practice
    RUN groupadd --gid 1000 node \
        && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
    USER node
    
    WORKDIR /usr/src/app
    
    # Copy installed dependencies from the builder stage
    COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
    
    # Copy application source code from the local repository's 'src' directory
    COPY --chown=node:node src/ .
    
    # Ensure the application listens on this port
    ENV PORT 3000
    EXPOSE 3000
    
    # Command to run the application
    # NOTE: Replace 'index.js' with your main entry file name (e.g., server.js)
    CMD ["node", "index.js"]
    