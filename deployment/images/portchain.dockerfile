FROM node:14.16.0-alpine3.10

# Create portchain user and groups to run app as non-root user for security.
RUN addgroup portchain \
    && adduser -S portchain -G portchain

WORKDIR /home/portchain/app
RUN chown portchain:portchain -R .

# Switch to portchain user so that we install dependencies 
# and also run the app by that user 
USER portchain

# Install dependencies, by copying only package*.json files we use the caching power of docker layers.
COPY package*.json ./
RUN yarn install

# Copy the whole project files
COPY . .

EXPOSE 3000

CMD ["yarn", "start"]