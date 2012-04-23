

class hosts {
    file {"/etc/hosts":
        ensure => file,
        owner => root,
        group => root,
        mode => 644,
        replace => true,
        content => template("hosts/hosts.erb"),
    }
}
