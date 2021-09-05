#!/bin/sh 

TTL=60
data=/home/dyndns/data


get_current_a()
{
    domain=$1
    # escape wildcard
    domain=${domain/\*/"\*"}
    linematch=$(grep -noP "(?<=\+$domain.:)[\d\.]*" $data)
    line=$(echo $linematch | cut -d":" -f1)
    ip4_old=$(echo $linematch | cut -d":" -f2)
}

construct_a()
{
    entry=+$1.:$2:$TTL
}

replace_a()
{
    sed -E "$1s/.*/$2/" $data > /tmp/foo
    cat /tmp/foo > $data
}




fqdn=$2
ip4_new=$3
get_current_a $fqdn
construct_a $fqdn $ip4_new
replace_a $line $entry
