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

# If run via ssh input arguments are passed as
# -c "first second third etc".
# Therefore, second argument has to be parsed
if test $# -eq 0; then
	echo "Illegal number of arguments."
	exit 1
fi
# split the string
fqdn=$(echo $2 | cut -d " " -f1)
ip_new=$(echo $2 | cut -d " " -f2)
# ip wasn't supplied, use ip from ssh client
if test $fqdn = $ip_new; then
	ip_new=${SSH_CLIENT%% *}
fi
# check currently set ip and only update if it differs from new ip
get_current_a $fqdn
if test $ip_new != $ip4_old; then
	construct_a $fqdn $ip_new
	replace_a $line $entry
fi
