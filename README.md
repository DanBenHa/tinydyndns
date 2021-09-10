On server
might need to stop and disable systemd-resolve service for port 53
or maybe not for udp?

On client

new user 
sudo adduser --system dyndns
new cronjob /etc/cron.d/dyndns
MAILTO="you@yourmail.com"
*/1  *  *  *  *  dyndns ssh -p 44 dyndns@ns1.example.com example.com > /dev/null
*/1  *  *  *  *  dyndns ssh -p 44 dyndns@ns1.example.com *.example.com > /dev/null
