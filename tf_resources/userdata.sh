#!/bin/bash
dnf update -y
dnf install -y httpd nmap nc

systemctl start httpd
systemctl enable httpd

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

PING_INTERNET=$(ping -c 3 amazon.com)

CIDR_BLOCKS="${cidr_blocks}"
ACCESIBLE_NEIGHBORS=$(nmap -p 22 --open $CIDR_BLOCKS -oG - | awk -v private_ip="$PRIVATE_IP" '/Up$/{if ($2 != private_ip) print $2}' | tr ' ' '\n')

cat <<EOF > /var/www/html/index.html
<html>
<head>
  <title>Instance Info</title>
</head>
<body>
  <h2>Instance Private IP: $PRIVATE_IP</h2>
  <h2>Ping Internet:</h2>
  <pre>$PING_INTERNET</pre>
  <h2>Accessible neighbours:</h2>
  <pre>$ACCESIBLE_NEIGHBORS</pre>
</body>
</html>
EOF

systemctl restart httpd