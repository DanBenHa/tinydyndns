#!/bin/sh 

TTL=60

get_current_a()
{
    domain=$1 
    data=/etc/tinydns/root/data
    #linematch=$(grep -noP "(?<=\+$domain.:)[\d\.]*" $data)
    linematch=$(grep -noP "(?<=\+$domain.:)[\d\.]*" $data)
    line=$(echo $linematch | cut -d":" -f1)
    ip4_old=$(echo $linematch | cut -d":" -f2)
}

construct_a()
{
    entry=\+$1.:$2:$TTL
    echo $entry
}

replace_a()
{
    data=/etc/tinydns/root/data
    sed -E "$1s/.*/$2/" $data > /tmp/foo
    cat /tmp/foo > $data
}

make_restart()
{
    cd /etc/tinydns/root
    make
    pid=$(pgrep tinydns)
    kill $pid
    cd /etc/tinydns
    ./run &
}




fqdn=$1
ip4_new=$2
get_current_a $fqdn
echo $line
echo $ip4_old
construct_a $fqdn $ip4_new
replace_a $line $entry
make_restart
