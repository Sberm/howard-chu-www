FROM ubuntu:plucky-20251001
WORKDIR /usr/src/app

RUN apt-get update
RUN apt-get -y install ruby-full build-essential zlib1g-dev nginx
RUN export GEM_HOME="$HOME/gems"
RUN export PATH="$HOME/gems/bin:$PATH"
RUN gem install jekyll bundler

COPY _config.yml favicon.ico 404.html Gemfile Gemfile.lock index.markdown resume.markdown .
COPY _posts _posts
COPY _includes _includes
COPY assets assets

RUN bundle
RUN bundle exec jekyll build

# RUN mkdir -p /etc/letsencrypt/live/howard-chu.com

COPY nginx.conf .
CMD ["nginx", "-g", "daemon off;", "-c", "/usr/src/app/nginx.conf"]