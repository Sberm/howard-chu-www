FROM ubuntu:plucky-20251001
WORKDIR /usr/src/app

RUN apt-get update
RUN apt-get -y install ruby-full build-essential zlib1g-dev nginx
RUN export GEM_HOME="$HOME/gems"
RUN export PATH="$HOME/gems/bin:$PATH"
RUN gem install jekyll bundler

COPY Gemfile Gemfile.lock .
RUN bundle install

COPY _config.yml favicon.ico 404.html resume.markdown index.html archives.md about.md feed.xml robots.txt .
COPY _posts _posts
COPY _data _data
COPY _layouts _layouts
COPY _includes _includes
COPY assets assets

RUN bundle exec jekyll build

COPY nginx.conf .
CMD ["nginx", "-g", "daemon off;", "-c", "/usr/src/app/nginx.conf"]
