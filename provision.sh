#!/bin/bash

# git submodule add -b production git@bitbucket.org:prolixalias/puppet-r10k-environments.git environments/production
# git submodule add -b production git@bitbucket.org:prolixalias/puppet-r10k-hiera.git hiera/production
#
#
#

puppet_environment=$1
ruby_version=$2

ruby_desired="ruby-${ruby_version}"
ruby_installed=`rvm current`
declare -a gems=("puppet" "facter" "hiera" "ruby-shadow" "json" "bundler" "librarian-puppet")

#/usr/bin/yum clean all
/usr/bin/yum update -y 
/usr/bin/yum install -y --quiet git
/usr/bin/yum remove -y ruby ruby-devel facter hiera puppet ruby-irb ruby-rdoc ruby-shadow rubygem-json rubygems
#/usr/bin/yum groupinstall -y "Development tools"

#cd /root
#mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
#wget -N ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p545.tar.gz -P rpmbuild/SOURCES
#wget -N https://raw.github.com/imeyer/ruby-1.9.3-rpm/master/ruby19.spec -P rpmbuild/SPECS
#rpmbuild -bb rpmbuild/SPECS/ruby19.spec
#yum localinstall /root/rpmbuild/RPMS/x86_64/ruby-1.9.3p545-1.el6.x86_64.rpm
#exit 0

if [ "${ruby_installed}" = "${ruby_desired}" ]; then
  echo "Ruby seems to be okay! ${ruby_installed}"
else  
  #/usr/bin/gpg2 --keyserver hkp://keys.gnupg.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  command /usr/bin/curl -sSL https://rvm.io/mpapis.asc | /usr/bin/gpg --import -
  /usr/bin/curl -L get.rvm.io | /bin/bash -s stable
  source /etc/profile.d/rvm.sh
  rvm get head
  rvm install ${ruby_version} 
  #gem update --system
fi

for gem in "${gems[@]}"; do
  if ! gem list ${gem} -i; then
    gem install ${gem} --no-ri --no-rdoc
  fi
done

#gem pristine executable-hooks --version 1.3.2
#gem pristine gem-wrappers --version 1.2.7
#gem pristine gem-wrappers --version 1.2.4
#gem update

if [ -f /vagrant/environments/${puppet_environment}/Puppetfile.lock ]; then
  echo "It seems librarian-puppet has been run previously"
else
  cd /vagrant/environments/${puppet_environment}/
  librarian-puppet install
fi

if [ -d /vagrant/environments/${puppet_environment} ]; then
  cd /vagrant/environments/${puppet_environment}/
  git pull
fi

if [ -d /vagrant/hiera/${puppet_environment}k ]; then
  cd /vagrant/hiera/${puppet_environment}/
  git pull
fi
