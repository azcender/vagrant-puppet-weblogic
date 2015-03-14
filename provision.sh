#!/bin/bash

### VARIABLES

puppet_environment=$1
ruby_version=$2
localdev_dir="/Users/ptalbot/sandbox/vagrant-puppet-localdev"
ruby_desired="ruby-${ruby_version}"
ruby_installed=`rvm current`
osfamily=`facter osfamily`

### ARRAYS

declare -a gems_install=("puppet" "facter" "hiera" "ruby-shadow" "json" "bundler" "librarian-puppet" "ruby-augeas" "augeas")
declare -a rpms_install=("libxml2-devel" "augeas-devel" "augeas-libs")
declare -a rpms_remove=("ruby-devel" "facter" "hiera" "puppet" "ruby-irIb" "ruby-rdoc" "ruby-shadow" "rubygem-json" "rubygems")
declare -a branches=("production" "paul" "ron" "dj" "suresh" "bryan")

### FUNCTIONS

vm_initial_yum () {
  #/usr/bin/yum clean all
  /usr/bin/yum install -y --quiet git
  for rpm in "${rpms_remove[@]}"; do
    if ! rpm -qa | grep -qw ${rpm}; then
      /usr/bin/yum remove -y --quiet ${rpm}
    fi
  done
  for rpm in "${rpms_install[@]}"; do
    if ! rpm -qa | grep -qw ${rpm}; then
      /usr/bin/yum install -y --quiet ${rpm}
    fi
  done
  /usr/bin/yum update -y
}

vm_setup_rvm () {
  if [ "${ruby_installed}" = "${ruby_desired}" ]; then
    echo "Ruby seems to be okay: ${ruby_installed}"
  else
    #/usr/bin/gpg2 --keyserver hkp://keys.gnupg.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    command /usr/bin/curl -sSL https://rvm.io/mpapis.asc | /usr/bin/gpg --import -
    /usr/bin/curl -L get.rvm.io | /bin/bash -s stable
    source /etc/profile.d/rvm.sh
    rvm get head
    rvm install ${ruby_version} --disable-binary
    rvm --default use ${ruby_version}
    #gem update --system
  fi
}

vm_install_gems () {
  for gem in "${gems_install[@]}"; do
    if ! gem list ${gem} -i; then
      gem install ${gem} --no-ri --no-rdoc
    fi
  done 
  #gem pristine executable-hooks --version 1.3.2
  #gem pristine gem-wrappers --version 1.2.7
  #gem pristine gem-wrappers --version 1.2.4
  #gem update
}

localdev_setup () {
  cd ${localdev_dir}
  #/usr/bin/git rm environments/*
  for branch in "${branches[@]}"; do
    cd ${localdev_dir}
    #/usr/bin/git submodule add --force -b ${branch} git@bitbucket.org:prolixalias/puppet-r10k-environments.git environments/${branch}
    #/usr/bin/git submodule add --force -b ${branch} git@bitbucket.org:prolixalias/puppet-r10k-hiera.git hiera/${branch}
    git submodule init
    git submodule update
    cd environments/${branch}
    mkdir modules
    if [ -f ${localdev_dir}/environments/${branch}/Puppetfile.lock ]; then
      echo "It seems librarian-puppet has been run previously"
    else
      cd ${localdev_dir}/environments/${branch}
      librarian-puppet install --verbose --clean
    fi
  done
}

### MAIN

case ${osfamily} in
  "Darwin")
    localdev_setup
  ;;
  "RedHat")
    vm_initial_yum
    vm_setup_rvm
    vm_install_gems
  ;;
  *)
    echo "Unsupported operating system (${osfamily})"
  ;;
esac

### EOF
