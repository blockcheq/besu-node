#!/bin/bash

function superuser {
  if ( type "sudo"  > /dev/null 2>&1 )
  then
    sudo $@
  else
    eval $@
  fi
}

function rhrequired {
  superuser yum clean all
  superuser yum -y update
  
  # Check EPEL repository availability. It is available by default in Fedora and CentOS, but it requires manual
  # installation in RHEL
  EPEL_AVAILABLE=$(superuser yum search epel | grep release || true)
  if [[ -z $EPEL_AVAILABLE ]];then
    echo "EPEL Repository is not available via YUM. Downloading"
    superuser yum -y install wget
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -O /tmp/epel-release-latest-7.noarch.rpm
    superuser yum -y install /tmp/epel-release-latest-7.noarch.rpm
  else 
    echo "EPEL repository is available in YUM via distro packages. Adding it as a source for packages"
    superuser yum -y install epel-release
  fi
  
  superuser yum -y update
  echo "Installing Libraries"
  curl -sL https://rpm.nodesource.com/setup_10.x | superuser bash -
  superuser yum -y install gmp-devel gcc gcc-c++ make openssl-devel libdb-devel\
                      ncurses-devel wget nmap-ncat libsodium-devel libdb-devel leveldb-devel nodejs
  npm install web3@1.2.0
  
  JDK_URL="https://download.oracle.com/otn-pub/java/jdk/13.0.1+9/cec27d702aa74d5a8630c65ae61e4305/jdk-13.0.1_linux-x64_bin.rpm"
  wget --no-check-certificate -c --header  "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O /tmp/jdk_linux-x64_bin.rpm
  
  pushd /tmp
  superuser yum -y install jdk_linux-x64_bin.rpm
  popd
  rm -rf /tmp/jdk_linux-x64_bin.rpm
  
  export JAVA_HOME=/usr/java/jdk-13.0.1
}

function debrequired {
  superuser apt-get update && superuser apt-get upgrade -y
  superuser apt-get install -y curl
  curl -sL https://deb.nodesource.com/setup_10.x | superuser bash -
  superuser apt-get install -y software-properties-common unzip wget git\
       make gcc libsodium-dev build-essential libdb-dev zlib1g-dev \
       libtinfo-dev sysvbanner psmisc libleveldb-dev\
       libsodium-dev libdb5.3-dev nodejs
  superuser npm install web3@1.2.0

  JDK_URL="https://download.oracle.com/otn-pub/java/jdk/13.0.1+9/cec27d702aa74d5a8630c65ae61e4305/jdk-13.0.1_linux-x64_bin.deb"
  wget --no-check-certificate -c --header  "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O /tmp/jdk_linux-x64_bin.deb
  
  pushd /tmp
  superuser dpkg -i jdk_linux-x64_bin.deb
  popd
  rm -rf /tmp/jdk_linux-x64_bin.deb
  
  export JAVA_HOME=/usr/lib/jvm/jdk-13.0.1
}

function installbesu {
  if ( ! type "besu" > /dev/null 2>&1 )
  then
  
    echo "Installing HYPERLEDGER BESU"
    
	pushd /tmp
    
	git clone --recursive https://github.com/hyperledger/besu.git
    cd besu
    git checkout 59096789cefefa6e8210e091dbe7ecdd9b1d8163
    ./gradlew build -x test
	
	cd build/distributions/
	tar -xzf besu-1.3.5-SNAPSHOT.tar.gz
	superuser cp besu-1.3.5-SNAPSHOT/bin/besu /usr/local/bin/
	superuser cp besu-1.3.5-SNAPSHOT/lib/* /usr/local/lib/
    
	popd
	
    rm -rf /tmp/besu
	unset JAVA_HOME
  fi
}

function rhconfigurepath {
# Manage JAVA_HOME variable
  if [[ -z "$JAVA_HOME" ]]; then
    echo 'export JAVA_HOME=/usr/java/jdk-13.0.1' >> $HOME/.bashrc
    export JAVA_HOME=/usr/java/jdk-13.0.1
    export PATH=$JAVA_HOME/bin:$PATH
    echo "[*] JAVA_HOME = $JAVA_HOME"
  fi

  exec "$BASH"

}

function debconfigurepath {
# Manage JAVA_HOME variable
  if [[ -z "$JAVA_HOME" ]]; then
    echo 'export JAVA_HOME=/usr/lib/jvm/jdk-13.0.1' >> $HOME/.bashrc
    export JAVA_HOME=/usr/lib/jvm/jdk-13.0.1
    export PATH=$JAVA_HOME/bin:$PATH
    echo "[*] JAVA_HOME = $JAVA_HOME"
  fi

  exec "$BASH"

}

function uninstallblockcheq {
  superuser rm /usr/local/bin/besu 2>/dev/null
  superuser rm /usr/local/lib/*.jar 2>/dev/null
  rm -rf /tmp/* 2>/dev/null
}

function installblockcheq {
  set -e
  OS=$(cat /etc/os-release | grep "^ID=" | sed 's/ID=//g' | sed 's\"\\g')
  if [ $OS = "centos" ] || [ $OS = "rhel" ]
  then
    rhrequired
  elif [ $OS = "ubuntu" ];then
    debrequired
  else
    echo 'This operating system is not yet supported'
    exit
  fi
  
  installbesu
  
  if [ $OS = "centos" ] || [ $OS = "rhel" ]
  then
    rhconfigurepath
  elif [ $OS = "ubuntu" ];then
    debconfigurepath
  fi
  
  set +e
}

if ( [ "uninstall" == "$1" ] )
then
   uninstallblockcheq
elif ( [ "reinstall" == "$1" ] )
then
   uninstallblockcheq
   installblockcheq
else
  installblockcheq
fi

echo "[*] Bootstrapping was completed successfully."
