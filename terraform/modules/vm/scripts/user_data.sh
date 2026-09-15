cat << 'EOF' > /c/cloud-devops-lab/terraform/modules/vm/scripts/user_data.sh
#!/bin/bash
apt-get update -y
apt-get install -y nginx

systemctl start nginx
systemctl enable nginx

HOSTNAME=$(hostname)

cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Day 05 - Cloud & DevOps Portfolio Lab</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 10%; background-color: #f4f4f9; }
        h1 { color: #0078d4; }
        .card { background: white; padding: 2rem; border-radius: 8px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Day 05 Complete!</h1>
        <p>Azure Load Balancer Active</p>
        <p><strong>Served by Node:</strong> $HOSTNAME</p>
    </div>
</body>
</html>
HTML
EOF

sed -i 's/\r$//' /c/cloud-devops-lab/terraform/modules/vm/scripts/user_data.sh