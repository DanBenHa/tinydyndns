#!/bin/sh 

TTL=60
data=/home/dyndns/data

is_ip()
{
    # test for ip4
    if test -z $(grep -oP "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"); then
        exit 1
    else
        exit 0
    fi
}

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

replace_record()
{
    sed -E "$1s/.*/$2/" $data > /tmp/foo
    cat /tmp/foo > $data
}

construct_txt()
{
    entry=\'$1.:$2:$TTL
}

append_record()
{
    echo $1 >> $data
}

remove_txt()
{
    # escape wildcard
    domain=${fqdn/\*/"\*"}
    # remove all txt records matching fqdn
    sed "/^'$domain/d" $data > /tmp/foo
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
if test $ip_new = "+txt"; then
    txt=$(echo $2 | cut -d " " -f3) 
    construct_txt $fqdn $txt
    append_record $entry
    exit 0   
fi
if test $ip_new = "-txt"; then
    remove_txt $fqdn
    exit 0   
fi
# ip wasn't supplied, use ip from ssh client
if test $fqdn = $ip_new; then
	ip_new=${SSH_CLIENT%% *}
fi
# check currently set ip and only update if it differs from new ip
get_current_a $fqdn
if test $ip_new != $ip4_old; then
	construct_a $fqdn $ip_new
	replace_record $line $entry
fi
