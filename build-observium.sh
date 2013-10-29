#!/bin/bash
#
# build-observium.sh
#
# Script to build a Observium package
#
# Requirements:
# - http access to observium tar.gz file (or SVN repo)
# - fpm installed (gem install fpm)
#
# author: johan.x.wennerberg@ericsson.com
# version: 1.0

usage()
{
  echo "usage: `basename $0` <osfamily> [<build source>] [<destination dir>]"
  echo ; echo "Supported osfamilies: debian"
}

### Main

osfamily=$1
buildsrc=$2
destdir=$3
[ -z $buildsrc ] && buildsrc='targz'
[ -z $destdir ] && destdir=/tmp

PATH="/bin:/usr/bin"

version='1.0'
release='2'

src_targz="http://www.observium.org/observium-community-latest.tar.gz"

case $osfamily in
  debian)
    package_type='deb'
    os=$osfamily
    deps='libapache2-mod-php5 php5-cli php5-mysql php5-gd php5-snmp php-pear snmp graphviz php5-mcrypt subversion mysql-client rrdtool fping imagemagick whois mtr-tiny nmap ipmitool python-mysqldb'
  ;;
  *)
  usage ; exit 1
  ;;
esac

builddir=`mktemp -d /tmp/observium.XXX`
swdir="${builddir}/observium"

package_arch='noarch'
package_name="observium-${version}-${release}.${package_arch}.${package_type}"
package_descr="Observium Network Management and Monitoring"
package_deps=`for i in $deps; do echo " -d $i" ;done`

if [ "$buildsrc" = 'targz' ]; then
  targz='observium.tar.gz'

  echo "Downloading package ${src_targz}"
  wget $src_targz -O ${builddir}/${targz}

  echo "Extracting package ${targz}"
  if [ ! -f "${builddir}/${targz}" ]; then
    echo "ERROR: Could not find archive ${builddir}/${targz}."
    exit 3
  fi

  cd $builddir && tar zxf $targz
else
  echo "ERROR: unknown buildsrc"
  exit 2
fi

echo "Building package observium"
if [ -d $swdir ]; then
  fpm -C $builddir -s dir -t $package_type -a $package_arch -n observium -p ${destdir}/${package_name} $package_deps -v $version --iteration ${release} --prefix /opt --description "$package_descr" --epoch $release observium
else
  echo "ERROR: Could not find observium directory ${swdir}"
  exit 3
fi
echo "Package written to ${destdir}/${package_name}"

echo "Cleaning up builddir"
rm -rf $builddir

