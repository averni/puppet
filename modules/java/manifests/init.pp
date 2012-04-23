
class java {
    file { "/usr/local/jdk-7u3-linux-x64.tar.gz":
        #source => "puppet://files/java/jdk-7u3-linux-x64.tar.gz",
        source => "/etc/puppet//files/java/jdk-7u3-linux-x64.tar.gz",
        alias  => "java-tgz",
        before => Exec["java-untar"]
    }

    exec { "tar xzf jdk-7u3-linux-x64.tar.gz":
        cwd       => "/usr/local/",
        creates   => "/usr/local/jdk1.7.0_03/",
        alias     => "java-untar",
        refreshonly => true,
        subscribe => File["java-tgz"]
    }

    exec { "ln -s /usr/local/jdk1.7.0_03/ /usr/local/java":
        cwd       => "/usr/local/",
        creates   => "/usr/local/java/",
        alias     => "java-link",
        subscribe => Exec["java-untar"],
    }

    exec { "rm jdk-7u3-linux-x64.tar.gz":
        cwd       => "/usr/local/",
        alias     => "java-rm-archive",
        unless    => "test -f jdk-7u3-linux-x64.tar.gz > /dev/null",
        require => Exec["java-link"]
    }
}

