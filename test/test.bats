setup_file () {
    # startup the docker-compose project 
    docker-compose up -d     
}

teardown_file () {
    # end the docker-compose project
    docker-compose down
}

@test "can telnet into updater's port 44" {
    echo -e '\x1dclose\x0d' | telnet localhost 44
}
@test "can get a DNS record" {
    dig -p 1053 @localhost example.com
}
