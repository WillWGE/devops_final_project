FROM node:18

# Create app directory & set the working directory in the container
RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

# Copy package.json  to the working directory
COPY package.json /usr/src/app/

# Install application dependencies
RUN npm install

# Install Sequelize CLI globally
RUN npm install -g sequelize-cli

# Copy the rest of the application code to the working directory
COPY . /usr/src/app

# Expose the port that the application will run on
EXPOSE 8000

# Define the command to run the application
CMD ["npm", "start"]
