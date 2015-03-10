FROM phusion/passenger-ruby22:0.9.15

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD config/nginx.conf /etc/nginx/sites-enabled/buildYourOwnSinatra.conf
RUN mkdir /home/apps/buildYourOwnSinatra

WORKDIR /home/apps/buildYourOwnSinatra

# Set up gems
ADD Gemfile /home/apps/buildYourOwnSinatra/Gemfile
ADD Gemfile.lock /home/apps/buildYourOwnSinatra/Gemfile.lock
RUN bundle install

# Finally, add the rest of our app's code
# (this is done at the end so that changes to our app's code
# don't bust Docker's cache)
ADD . /home/apps/buildYourOwnSinatra

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
