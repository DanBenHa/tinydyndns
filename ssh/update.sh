#!/bin/sh 

TTL=60
data=/home/dyndns/data
IP4_DEFAULT=$(cat /home/dyndns/IP4_DEFAULT)
IP6_DEFAULT=$(cat /home/dyndns/IP6_DEFAULT)

get_current_record()
{
    domain=$1
    # escape wildcard
    domain=${domain/\*/"\*"}

    prefix=$2
    # escape plus
    prefix=${prefix/\+/"\+"}

    linematch=$(grep -noP "(?<=$prefix$domain.:)[\d\.]*" $data)
    line=$(echo $linematch | cut -d":" -f1)
    record_old=$(echo $linematch | cut -d":" -f2)
}

construct_record()
{
    entry=$1$2.:$3:$TTL
}

replace_record()
{
    sed -E "$1s/.*/$2/" $data > /tmp/data
    cat /tmp/data > $data
    rm /tmp/data
}

ipv4_prep(){
    ipv=4
    prefix="+"
    if [[ -z $1 ]]
    then
        ip_new=$arg1
    else
        ip_new=$1
    fi
}

ipv6_prep(){
    ipv=6
    prefix="3"
    # expand ipv6
    ip_new=$(grep -e "Expanded Address" /tmp/sipcalc | cut -d " " -f3)
    # remove the colons
    ip_new=${ip_new//\:/}
}

check_construct_replace(){
    # Check currently set IP and only update if it differs from new IP
    get_current_record $fqdn $prefix
    if test $ip_new != $record_old; then
        construct_record $prefix $fqdn $ip_new
        replace_record $line $entry
    fi
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
arg1=$(echo $2 | cut -d " " -f2)

# Add/remove TXT record
if test $arg1 = "+txt"; then
    txt=$(echo $2 | cut -d " " -f3) 
    prefix="\'"
    construct_record $prefix $fqdn $txt
    # append TXT
    echo $entry >> $data
    exit 0
elif test $arg1 = "-txt"; then
    # escape wildcard
    domain=${fqdn/\*/"\*"}
    # remove all txt records matching fqdn
    sed "/^'$domain/d" $data > /tmp/data
    cat /tmp/data > $data
    rm /tmp/data
    exit 0
fi

# If no argument was supplied use IP from SSH_CLIENT
if test $fqdn = $arg1; then
    arg1=${SSH_CLIENT%% *}
fi

# Test if first argument is valid IP
sipcalc $arg1 > /tmp/sipcalc
if test $(grep -c "ERR" /tmp/sipcalc) -eq 1
then
    echo "Illegal argument."
    rm /tmp/sipcalc
    exit 1
fi

# real IPs
if test $(grep -c "ipv4" /tmp/sipcalc) -eq 1
then
    ipv4_prep
    check_construct_replace
    if [[ -n $IP6_DEFAULT ]]
    then
        sipcalc $IP6_DEFAULT > /tmp/sipcalc
        ipv6_prep
        check_construct_replace
    fi
elif test $(grep -c "ipv6" /tmp/sipcalc) -eq 1
then
    ipv6_prep
    check_construct_replace
    if [[ -n $IP4_DEFAULT ]]
    then
        ipv4_prep $IP4_DEFAULT
        check_construct_replace
    fi
fi
rm /tmp/sipcalc
exit 0
