setup_file () {
    cp test/data_test_template test/data_test
    chown 1000:1000 test/data_test
    # start the docker-compose app 
    docker-compose --env-file test/env_test up -d     
    # start the tester container
    docker run --ip 13.33.33.37 --rm --network=tinydyndns_test -d --name tester tester tail -f /dev/null
}
setup () {
    load 'test_helper/bats-support/load' # this is required by bats-assert!
    load 'test_helper/bats-assert/load'
}

teardown_file () {
    # end tester container
    docker stop tester
    # end the docker-compose app
    docker-compose down
    rm test/data_test
}

testit () {
    docker exec tester sh -c "$*"
}

@test "can telnet into updater's port 22" {
    run testit "echo -e \'\x1dclose\x0d\' | telnet updater 22"
    assert_success
}

@test "can ssh into updater" {
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater"
    # fail because this returns exit 1
    assert_failure
    echo "Illegal number of arguments." | assert_output
}

@test "can get a DNS record" {
    run testit "dig @tinydns example.com"
    assert_success
}

@test "correct default soa" {
    lastmod=$(stat -c %Y test/data_test)
    run testit "dig +short SOA @tinydns example.com"
    assert_output "ns1.example.com. hostmaster.example.com. ${lastmod} 16384 2048 1048576 2560"
}

@test "correct default A records" {
    run testit "dig +short A @tinydns ns1.example.com"
    assert_output 1.1.1.1

    run testit "dig +short A @tinydns ns2.example.com"
    assert_output "2.2.2.2"

    run testit "dig +short A @tinydns example.com"
    assert_output "3.3.3.3"

    run testit "dig +short A @tinydns *.example.com"
    assert_output "4.4.4.4"
}

@test "correct default AAAA records" {
    run testit "dig +short AAAA @tinydns ns1.example.com"
    assert_output "2606:4700:4700::1111"

    run testit "dig +short AAAA @tinydns ns2.example.com"
    assert_output "2606:4700:4700::2222"

    run testit "dig +short AAAA @tinydns example.com"
    assert_output "2606:4700:4700::3333"

    run testit "dig +short AAAA @tinydns *.example.com"
    assert_output "2606:4700:4700::4444"
}

@test "change A" {
    # non-wildcard #

    # check default
    run testit "dig +short A @tinydns example.com"
    assert_output "3.3.3.3"

    # change entry 
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater example.com 1.1.1.1"
    assert_success

    # check changed
    sleep 0.1
    run testit "dig +short A @tinydns example.com"
    assert_output "1.1.1.1"


    # wildcard #

    # check default
    run testit "dig +short A @tinydns *.example.com"
    assert_output "4.4.4.4"
    
    # change entry
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater *.example.com 5.5.5.5"
    assert_success

    # check changed
    sleep 0.1
    run testit "dig +short A @tinydns *.example.com"
    assert_output "5.5.5.5"
}

@test "change AAAA" {
    # non-wildcard
    run testit "dig +short AAAA @tinydns example.com"
    assert_output "2606:4700:4700::3333"
    
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater example.com 2606:4700:4700::1337"
    assert_success
    sleep 0.1
    run testit "dig +short AAAA @tinydns example.com"
    assert_output "2606:4700:4700::1337"

    # wildcard
    run testit "dig +short AAAA @tinydns *.example.com"
    assert_output "2606:4700:4700::4444"
    
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater *.example.com 2606:4700:4700::7331"
    assert_success
    sleep 0.1 
    run testit "dig +short AAAA @tinydns *.example.com"
    assert_output "2606:4700:4700::7331"
}

@test "change A to tester ip" {
    run testit "ssh -o \"StrictHostKeyChecking no\" -i /etc/ssh/hostkey -q dyndns@updater example.com"
    assert_success

    sleep 0.1
    run testit "dig +short A @tinydns example.com"
    assert_output "13.33.33.37"
}
