
define yumgroup($ensure = "present", $optional = false, $unless) {
   case $ensure {
      present,installed: {
         $pkg_types_arg = $optional ? {
            true => "--setopt=group_package_types=optional,default,mandatory",
            default => ""
         }
         exec { "Installing $name yum group":
            command => "yum -y groupinstall $pkg_types_arg \"$name\"",
            #unless => "yum -y groupinstall $pkg_types_arg \"$name\" --downloadonly",
            unless => $unless,
            timeout => 600,
         }
      }
   }
}


class python27 {
    yumgroup { "Development Tools":
        unless  => "test -f /usr/bin/make"
    }

    package { [ "ncurses-devel", "readline-devel", "db4-devel", "zlib-devel", "sqlite-devel", "openssl-devel", "ImageMagick-devel" ]:
        ensure  => installed,
        before  => Exec['python-untar']
    }

    file { "/opt/Python-2.7.2.tgz":
        #source => "puppet://files/python/Python-2.7.2.tgz",
        source => "/etc/puppet/files/python/Python-2.7.2.tgz",
        alias  => "python-tgz",
        before => Exec["python-untar"]
    }

    exec { "tar xzf Python-2.7.2.tgz":
        cwd         => "/opt",
        creates     => "/opt/Python-2.7.2",
        alias       => "python-untar",
        refreshonly => true,
        unless      => "test -f /usr/local/bin/python2.7"
    }

    exec { "configure" :
        command   => "sh ./configure --enable-shared && make altinstall",
        cwd       => "/opt/Python-2.7.2/",
        alias     => "python-make",
        require   => [yumgroup["Development Tools"]],
        subscribe => Exec['python-untar'],
        unless      => "test -f /usr/local/bin/python2.7"
    }

    exec { "rm -rf ./Python-2.7.2*":
        cwd       => "/opt",
        alias     => "python-rm-archive",
        unless    => "test -f Python-2.7.2.tgz",
        require   => Exec["python-untar"]
    }

    file { "/etc/ld.so.conf.d/python2.7.conf":
        ensure          => present,
        content         => "/usr/local/lib/",
        subscribe       => Exec['python-make']
    }

    exec { "ldconfig":
        subscribe       => File["/etc/ld.so.conf.d/python2.7.conf"],
        refreshonly     => true
    }

    file { "/opt/setuptools-0.6c11.tar.gz":
        #source => "puppet://files/python/setuptools-0.6c11.tar.gz",
        source          => "/etc/puppet/files/python/setuptools-0.6c11.tar.gz",
        before          => Exec["setuptool-install"],
    }

    exec { "setuptools-install":
        cwd             => "/opt",
        command         => "tar zxf setuptools-0.6c11.tar.gz && cd setuptools-0.6c11 && python2.7 setup.py install",
        alias           => "setuptool-install",
        subscribe       => Exec['python-make'],
        refreshonly     => true
    }

    exec { "pip-install":
        cwd             => "/opt",
        command         => "easy_install pip",
        subscribe       => Exec['setuptools-install'],
        refreshonly     => true
    }

}
