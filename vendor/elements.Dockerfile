FROM node:18
RUN git clone https://github.com/epfl-si/elements.git
WORKDIR /elements
RUN yarn
RUN yarn dist