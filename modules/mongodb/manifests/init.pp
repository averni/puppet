

class mongodb {
    user { 'mongodb':
        ensure  => 'present',
        comment => 'MongoDB user,,,',
        gid     => 1005,
        home    => '/home/mongodb',
        shell   => '/bin/sh',
        uid     => '114',
    }

    group {"mongodb":
        ensure => present,
        gid => 1005
    }

    file { "/usr/local/mongodb-linux-x86_64-2.0.4.tgz":
        #source => "puppet://files/mongodb/mongodb-linux-x86_64-2.0.4.tgz",
        source => "/etc/puppet//files/mongodb/mongodb-linux-x86_64-2.0.4.tgz",
        alias  => "mongodb-tgz",
        before => Exec["mongodb-untar"]
    }

    exec { "tar xzf mongodb-linux-x86_64-2.0.4.tgz":
        cwd       => "/usr/local/",
        creates   => "/usr/local/mongodb-linux-x86_64-2.0.4/",
        alias     => "mongodb-untar",
        refreshonly => true,
        subscribe => File["mongodb-tgz"]
    }

    exec { "ln -s /usr/local/mongodb-linux-x86_64-2.0.4/ /usr/local/mongodb":
        cwd       => "/usr/local/",
        creates   => "/usr/local/mongodb/",
        alias     => "mongodb-link",
        subscribe => Exec["mongodb-untar"],
    }

    exec { "mkdir /usr/local/mongodb-linux-x86_64-2.0.4/{data,etc,logs}":
        cwd       => "/usr/local/",
        creates   => "/usr/local/mongodb/logs",
        alias     => "mongodb-mkdirs",
        subscribe => Exec["mongodb-untar"],
    }

    file { "/usr/local/mongodb/etc/mongod.conf":
        #source => "puppet://files/mongodb/mongod.conf",
        source => "/etc/puppet/files/mongodb/mongod.conf",
        alias  => "mongodb-config",
        subscribe => Exec["mongodb-link"]
    }

    #if $is_master == 'true' {
    #    file { "/usr/local/mongodb/etc/mongod.conf":
    #        #source => "puppet://files/mongodb/mongod.conf.master",
    #        source => "/etc/puppet/files/mongodb/mongod.conf.master",
    #        alias  => "mongodb-config",
    #        subscribe => Exec["mongodb-mkdirs"]
    #    }
    #} else {
    #    file { "/usr/local/mongodb/etc/mongod.conf":
    #        #source => "puppet://files/mongodb/mongod.conf.slave",
    #        source => "/etc/puppet/files/mongodb/mongod.conf.slave",
    #        alias  => "mongodb-config",
    #        subscribe => Exec["mongodb-mkdirs"]
    #    }
    #}
 
    $mongoinit = $operatingsystem ? {
        centos  => "mongod.rhel.init",
        redhat  => "mongod.rhel.init",
        debian  => "mongod.deb.init",
        ubuntu  => "mongod.deb.init",
    }

    file { "/etc/init.d/mongod":
        #source => "puppet://files/mongodb/$mongoinit",
        source => "/etc/puppet//files/mongodb/$mongoinit",
        alias  => "mongodb-initscript",
        subscribe  => File["mongodb-config"]
    }

    exec { "rm mongodb-linux-x86_64-2.0.4.tgz":
        cwd       => "/usr/local/",
        alias     => "mongodb-rm-archive",
        unless    => "test ! -f /usr/local/mongodb-linux-x86_64-2.0.4.tgz > /dev/null",
        subscribe  => Exec["mongodb-link"]
    }

    service { "mongod":
        enable => true,
        ensure => running,
        require => File['mongodb-initscript'],
    }


}
