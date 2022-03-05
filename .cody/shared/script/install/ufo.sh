#!/bin/bash

set -eux

export PATH=~/bin:$PATH

cat << 'EOF' > ~/.gemrc
---
:backtrace: false
:bulk_threshold: 1000
:sources:
- https://rubygems.org
:update_sources: true
:verbose: true
benchmark: false
install: "--no-ri --no-rdoc --no-document"
update: "--no-ri --no-rdoc --no-document"
EOF

gem install bundler # upgrade bundler

# In original ufo source and install ufo
cd $CODEBUILD_SRC_DIR # ufo folder - in case code is added later above this that uses cd
bundle install
bundle exec rake install

mkdir -p ~/bin
cat << EOF > ~/bin/ufo
#!/bin/bash
# If there's a Gemfile, assume we're in a ufo project with a Gemfile for ufo
if [ -f Gemfile ]; then
  exec bundle exec $CODEBUILD_SRC_DIR/exe/ufo "\$@"
else
  exec $CODEBUILD_SRC_DIR/exe/ufo "\$@"
fi
EOF

cat ~/bin/ufo

chmod a+x ~/bin/ufo
