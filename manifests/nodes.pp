

$nagiosserverip = '176.31.239.132'
define pkglist_helper(){
    $pkg  = inline_template('<%= name.split(";")[0] -%>')
    $next = inline_template('<%= name.split(";")[1] or "" -%>')

    if $next != "" {
        package { $pkg:
            ensure => installed,
            before => Package[$next];
        }
    } else {
        package { $pkg:
                ensure => installed;
        }
    }
}

define packagelist($packages) {
    notify { $packages:
    }
    $foo = inline_template(
         '<% lst = []; 0.upto(packages.length - 1) { |i|
             lst << packages[i] + ";" + (packages[i+1] or "");
          } -%><%=lst.join("|") -%>')
    $bar = split($foo, "[|]")

    pkglist_helper {
        $bar: ;
    }
}

define python27_install($modulename = '', $packagename = '', $pkgs = '', $verbose = false, $using = 'easy_install') {
    $module = $modulename ? {
        ''          => $title,
        default     => $modulename
    }

    $package = $packagename ? {
        ''          => $module,
        default     => $packagename
    }

    $cmd = $using ? {
        'easy_install'      => "easy_install-2.7 ${package}",
        'pip'               => "pip-2.7 install ${package}",
    }

    exec { "python-install-${module}":
       command      => $cmd,
       unless       => "python2.7 -c 'import ${module}'",
       logoutput    => $verbose 
    }

    if $pkgs {
        #notify{ $pkgs:
        notify{ "messaggio-${title}":
            withpath    => true,
            message     => "MESSAGIO ${pkgs}",
        }

        /*
        package { $pkgs :
            ensure => present,
        }
        */

        packagelist { "pkgs-${title}" :
             packages => $pkgs
        }

        Exec["python-install-$module"] {
            #require +> $pkgs,
            #subscribe +> $requires,
        }
    }

}

class python27-package {
    # PYTHON PACKAGES
    python27_install { 'pycurl':
        modulename      => "pycurl",
        pkgs            => [ "libcurl-devel" ],
    }

    python27_install { 'MySQLdb':
        modulename      => "MySQLdb",
        packagename     => "mysql-python",
    }

    python27_install { 'virtualenv':
    }

    python27_install { 'stomp':
        packagename     => 'stomp.py'
    }

    python27_install { 'BeautifulSoup':
    }

    python27_install { 'stripogram':
    }

    python27_install { "python-utils":
        modulename  => "configobj",
        packagename => "python-utils",
        using       => "pip",
    }

    python27_install { "zope.interfaces":
        using       => "pip",
    }

    python27_install{ "lxml":
        pkgs    => [ 'libxml2-devel', 'libxslt-devel' ],
    }

    python27_install { "pymongo":
    }

    python27_install { "pycassa":
        packagename => "thrift pycassa",
    }

    python27_install { "simplejson":
    }

    python27_install { "django":
    }

    /*
    package { 'libcurl-devel':
        ensure => present
    }

    exec { "easy_install-2.7 pycurl":
        unless   => 'python2.7 -c "import pycurl"',
        logoutput => true,
    #    Centos  => "MySQL-python",
    #    Debian  => "python-mysqldb",
    #}
    #package { "$pythonmysqldb":
    #    ensure => present
    #}


    exec { "easy_install-2.7 mysql-python":
       unless   => 'python2.7 -c "import MySQLdb"',
        logoutput => true,
    }

    exec { "easy_install-2.7 virtualenv":
       unless   => 'python2.7 -c "import virtualenv"',
    }

    exec { "easy_install-2.7 stomp.py":
       unless   => 'python2.7 -c "import stomp"',
    }

    exec { "easy_install-2.7 BeautifulSoup":
       unless   => 'python2.7 -c "import BeautifulSoup"',
    }

    exec { "easy_install-2.7 stripogram":
       unless   => 'python2.7 -c "import stripogram"',
    }

    exec { "pip-2.7 install python-utils":
       unless   => 'python2.7 -c "import configobj"',
    }

    exec { "pip-2.7 install zope.interfaces":
       unless   => 'python2.7 -c "import zope.interface"',
    }

    package { 'libxml2-devel':
        ensure => present
    }

    package { 'libxslt-devel':
        ensure => present
    }

    exec { "easy_install-2.7 lxml":
       unless   => 'python2.7 -c "import lxml"',
        subscribe => [Package["libxml2-devel"], Package["libxslt-devel"]]
    }

    exec { "easy_install-2.7 pymongo":
       unless   => 'python2.7 -c "import pymongo"',
    }

    exec { "easy_install-2.7 thrift pycassa":
       unless   => 'python2.7 -c "import pycassa"',
    }

    exec { "easy_install-2.7 simplejson":
       unless   => 'python2.7 -c "import simplejson"',
    }

    exec { "easy_install-2.7 django":
       unless   => 'python2.7 -c "import django"',
    }
    */
}



class yoodealbase {
    user { 'yoodeal':
        shell => '/bin/bash',
        uid => '1000',
        gid => '1000',
        comment => 'Yoodeal',
        ensure => 'present',
        password => '$1$NbCTDtih$Ukxb3FQ3ey.lUqKTnSqgu1',
        home => '/home/yoodeal',
        managehome => true
    }

    group {"yoodeal":
        ensure => present,
        gid => 1000
    }

    package { 'munin-node':
        ensure => present,
    }

    package { 'nrpe':
        ensure => present
    }

    package { 'nagios-plugins':
        ensure => present
    }

    package { 'subversion':
        ensure => present
    }

    package { 'git':
        ensure => present
    }

    include java
    include python27
    include python27-package
    include mongodb

    #file { "/etc/yum.repos.d/10gen-mongodb.repo":
    #    ensure      => "present",
    #    #source     => "/etc/puppet/files/python/setuptools-0.6c11.tar.gz",
    #    source      => $operatingsystem ? {
    #        'redhat' =>  "puppet://mongodb/10gen-mongodb.repo",
    #        'centos' =>  "puppet://mongodb/10gen-mongodb.repo",
    #        'debian' =>  "puppet://mongodb/10gen-mongodb.sources.list",
    #    }
    #}
    #include nrpe
    #class{ 'nrpe':
    #    source   => [ "puppet:///modules/nrpe/nrpe.conf-${hostname}" , "puppet:///modules/nrpe/nrpe.conf" ],
    #    template => undef
    #}
}

node default {
    include yoodealbase
}

node yoodeal-puppetslave {
    include yoodealbase        
    include hosts
    include java
}
