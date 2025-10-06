# --- STAGE 1: Build & Dependency Installation (to compile node_modules securely) ---
    FROM node:20-slim AS base
    # Set working directory inside the container
    WORKDIR /usr/src/app
    
    # Copy necessary files for dependency installation (these are needed for npm install)
    # Using explicit path notation for best practice
    COPY ./package.json ./package-lock.json ./
    
    # Install production dependencies (using npm ci for cleaner builds)
    RUN npm ci --production
    
    # --- STAGE 2: Production Image (Minimal and Secure) ---
    # Use the same slim base image for the final production image
    FROM node:20-slim AS final
    # Set working directory
    WORKDIR /usr/src/app
    
    # Copy installed node_modules from the build stage
    COPY --from=base /usr/src/app/node_modules ./node_modules
    
    # Copy source code and package files from local repo
    # Explicitly use ./ for robust context reference
    COPY ./src/ ./src/ 
    COPY ./package.json .
    COPY ./package-lock.json .
    
    # Expose the port the app runs on (matching the value in your task definition)
    EXPOSE 3000
    
    # Use the pre-existing 'node' user from the slim image for security.
    # This avoids the groupadd/useradd failure.
    USER node
    
    # Command to run the application (Must point to the correct entry file, app.js)
    CMD ["node", "src/app.js"]
    