import "nodes.pp"
$puppetserver = "yoodeal-puppetmaster"

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "." ] }
