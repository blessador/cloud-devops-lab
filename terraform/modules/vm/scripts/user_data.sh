#!/bin/bash
# System updates & NGINX installation
apt-get update -y
apt-get install -y nginx

# Ensure NGINX is enabled and running
systemctl start nginx
systemctl enable nginx

# Inject custom landing page
cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Day 04 - Cloud & DevOps Portfolio Lab</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 10%; background-color: #f4f4f9; }
        h1 { color: #0078d4; }
        .card { background: white; padding: 2rem; border-radius: 8px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="card">
        <h1>Day 04 Complete!</h1>
        <p>Automated NGINX Web Server Provisioned via Terraform & Cloud-Init</p>
        <p><strong>Region:</strong> Austria East</p>
    </div>
</body>
</html>
HTML
