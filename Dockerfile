#---------base----------------
FROM node:14 as base
# Create app directory
WORKDIR /usr/src/app

#-----------dependencies--------------
FROM base AS dependencies
WORKDIR /usr/src/app
# Install app dependencies
COPY  package*.json ./
COPY tsconfig.build.json tsconfig.json nest-cli.json ./
RUN npm install

#------------build-------------
FROM dependencies AS build
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY ./src /usr/src/app
# Build the application
RUN npm run build

#------------release-------------
FROM node:14-alpine AS release
ENV NODE_ENV production
WORKDIR /usr/src/app
# Bundle app source
COPY --from=dependencies /usr/src/app/package*.json ./
# Install app dependencies
RUN npm ci --only=production
# Copy the dist dir
COPY --from=build /usr/src/app/dist/ /usr/src/app/dist
EXPOSE 4000
CMD ["npm", "run", "start:prod"]
