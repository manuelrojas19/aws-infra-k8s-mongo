#!/bin/sh

MONGO_USER=${MONGO_USER}
MONGO_PASSWORD=${MONGO_PASSWORD}
REGION=${REGION}
CERT_S3_BUCKET=${CERT_S3_BUCKET}

echo "------------------------------------------"
echo "Starting MongoDB provisioning in ${REGION}"
echo "------------------------------------------"

#Update OS and install required packages
sudo yum update -y
sudo yum install unzip zip jq -y

#Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/home/ec2-user/awscliv2.zip"
sudo unzip /home/ec2-user/awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

# Get the instance ID of the current EC2 instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Use AWS CLI to get the tags of the instance
TAGS=$(/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region $REGION --output json)

# Parse the tags and extract the Name tag value
TAG_NAME=$(echo "$TAGS" | jq -r '.Tags[] | select(.Key=="Name") | .Value')

# Check if the tag value contains "mongodb-1", "mongodb-2", or "mongodb-3"

if [[ $TAG_NAME == *"mongodb-node-1"* ]]; then
    # Set hostname for mongodb-1
    sudo hostnamectl set-hostname mongodb.node1.mrr.com
    DOMAIN_NAME="mongodb.node1.mrr.com"

elif [[ $TAG_NAME == *"mongodb-node-2"* ]]; then
    # Set hostname for mongodb-2
    sudo hostnamectl set-hostname mongodb.node2.mrr.com
    DOMAIN_NAME="mongodb.node2.mrr.com"
  
elif [[ $TAG_NAME == *"mongodb-node-3"* ]]; then
    # Set hostname for mongodb-3
    sudo hostnamectl set-hostname mongodb.node3.mrr.com
    DOMAIN_NAME="mongodb.node3.mrr.com"
  
else
    echo "No matching tag found for hostname assignment." 
fi

# Create a list file for MongoDB
# Define the repository content
REPO_CONTENT="[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc"

# Write the repository content to the file

echo "$REPO_CONTENT" | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo

# Verify that the file was created successfully
if [ -f /etc/yum.repos.d/mongodb-org-7.0.repo ]; then
    echo "MongoDB repository file created successfully."
else
    echo "Failed to create MongoDB repository file." 
fi


# Install the MongoDB packages
sudo yum install -y mongodb-org-7.0.1

# Append the line to /etc/yum.conf
echo "exclude=mongodb-org,mongodb-org-database,mongodb-org-server,mongodb-mongosh,mongodb-org-mongos,mongodb-org-tools" | sudo tee -a /etc/yum.conf

# Start MongoDB
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl status mongod
chkconfig mongod on

sleep 60
#Give the Admin user with the userAdminAnyDatabase and readWriteAnyDatabase roles"

sudo mongosh <<EOF
use admin
db.createUser(
  {
    user: "$MONGO_USER",
    pwd: "$MONGO_PASSWORD", 
    roles: [ { role: "root", db: "admin" }]
  }
)
EOF

#Copy SSL certificates to /etc/mongodb/ssl from S3 bucket
sudo mkdir -p /etc/mongodb/ssl
sudo chmod 700 /etc/mongodb/ssl
sudo chown -R mongod:mongod /etc/mongodb
sudo /usr/local/bin/aws s3 cp s3://$CERT_S3_BUCKET/mongoCA.crt /etc/mongodb/ssl
sudo /usr/local/bin/aws s3 cp s3://$CERT_S3_BUCKET/mongo.pem /etc/mongodb/ssl

#disable Transparent Huge Pages and THP defragmentation on a Linux system
disable_transparent_hugepages_CONTENT="
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
exit 0"

echo "$disable_transparent_hugepages_CONTENT" | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local

#set soft limit for the number of processes
echo "mongod soft nproc 64000" | sudo tee -a /etc/security/limits.conf
echo "vm.max_map_count=262144"|sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sysctl vm.max_map_count

# define mongod.conf
mongo_conf_CONTENT="# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo

# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1,$DOMAIN_NAME # Enter 0.0.0.0,:: to bind to all IPv4 and IPv6 addresses or, alternatively, use the net.bindIpAll setting.
  unixDomainSocket:
     enabled: true
     pathPrefix: /var/run/mongodb
  ssl:
     mode: requireTLS
     PEMKeyFile: /etc/mongodb/ssl/mongo.pem
     CAFile: /etc/mongodb/ssl/mongoCA.crt
     clusterFile: /etc/mongodb/ssl/mongo.pem

security:
  authorization: enabled
  clusterAuthMode: x509

#operationProfiling:

replication:
  replSetName: mongodbMrrMesh

#sharding:

## Enterprise-Only Options

#auditLog:"

# Update mongod config
echo "$mongo_conf_CONTENT" | sudo tee /etc/mongod.conf

# Restart nodes
sudo systemctl restart mongod

# Backup Script 
backup_script="#!/bin/bash

# Define MongoDB connection details
MONGO_PORT="27017"
MONGO_USER=$MONGO_USER
MONGO_PASSWORD=$MONGO_PASSWORD
CAFile="/etc/mongodb/ssl/mongoCA.crt"
CertificateKeyFile=/etc/mongodb/ssl/mongo.pem
current_day=$(date +'%d')
current_month=$(date +'%m')
current_year=$(date +'%Y')
s3_backup_bucket=$CERT_S3_BUCKET
DIRECTORY="/opt/backup/data"

# Check if the instance is a secondary

IS_MONGO2_SECONDARY=$(sudo mongosh --tls --tlsCAFile $CAFile --tlsCertificateKeyFile $CertificateKeyFile -u $MONGO_USER -p $MONGO_PASSWORD  --host=mongodb.node2.mrr.com:27017 --eval "db.isMaster().secondary")
IS_MONGO2_SECONDARY=$(echo "$IS_MONGO3_SECONDARY" | grep -o -w "true")

IS_MONGO3_SECONDARY=$(sudo mongosh --tls --tlsCAFile $CAFile --tlsCertificateKeyFile $CertificateKeyFile -u $MONGO_USER -p $MONGO_PASSWORD  --host=mongodb.node3.mrr.com:27017 --eval "db.isMaster().secondary")
IS_MONGO3_SECONDARY=$(echo "$IS_MONGO3_SECONDARY" | grep -o -w "true")

if [ "$IS_MONGO3_SECONDARY" == "true" ]; then
  echo "mongodb.node3.io is a secondary instance. Proceeding with backup..."
  # Perform mongodump
  sudo mongodump --ssl --sslCAFile $CAFile --sslPEMKeyFile $CertificateKeyFile  --host=mongodb.node3.mrr.com --port=27017 --username=$MONGO_USER --password=$MONGO_PASSWORD --authenticationDatabase=admin --oplog --out=$DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo tar -czvf $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo /usr/local/bin/aws s3 cp $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $s3_backup_bucket/mongodump-$current_day-$current_month-$current_year
  find "$DIRECTORY" -type f -mtime +1 -exec rm {} \;
  echo "Backup completed successfully." 
elif [ "$IS_MONGO2_SECONDARY" == "true" ]; then
  echo "mongodb.node2.io is a secondary instance. Proceeding with backup..."
  # Perform mongodump
  sudo mongodump --ssl --sslCAFile $CAFile --sslPEMKeyFile $CertificateKeyFile  --host=mongodb.node2.mrr.com --port=27017 --username=$MONGO_USER --password=$MONGO_PASSWORD --authenticationDatabase=admin --oplog --out=$DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo tar -czvf $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo /usr/local/bin/aws s3 cp $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $s3_backup_bucket/mongodump-$current_day-$current_month-$current_year
  find "$DIRECTORY" -type f -mtime +1 -exec rm {} \;
  echo "Backup completed successfully."
else
  echo "mongodb.node1.io is a secondary instance. Proceeding with backup..."
  # Perform mongodump
  sudo mongodump --ssl --sslCAFile $CAFile --sslPEMKeyFile $CertificateKeyFile  --host=mongodb.node1.mrr.com --port=27017 --username=$MONGO_USER --password=$MONGO_PASSWORD --authenticationDatabase=admin --oplog --out=$DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo tar -czvf $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $DIRECTORY/mongodump-$current_day-$current_month-$current_year
  sudo /usr/local/bin/aws s3 cp $DIRECTORY/mongodump-$current_day-$current_month-$current_year.tar.gz $s3_backup_bucket/mongodump-$current_day-$current_month-$current_year
  find "$DIRECTORY" -type f -mtime +1 -exec rm {} \;
fi"

if [[ $TAG_NAME == *"mongodb-node-1"* ]]; then
    # Add a wait time of 5 seconds
    sleep 30
    sudo mongosh admin --tls --tlsCAFile /etc/mongodb/ssl/mongoCA.crt --tlsCertificateKeyFile /etc/mongodb/ssl/mongo.pem -u $MONGO_USER -p $MONGO_PASSWORD --host mongodb.node1.mrr.com <<EOF
    rs.initiate( {
    _id : "mongodbMrrMesh",
    members: [
        { _id: 0, host: "mongodb.node1.mrr.com:27017" },
        { _id: 1, host: "mongodb.node2.mrr.com:27017" },
        { _id: 2, host: "mongodb.node3.mrr.com:27017" }
    ]
    })
EOF

elif [[ $TAG_NAME == *"mongodb-node-2"* ]]; then
    # Set hostname for mongodb-2
    sleep 220
  
elif [[ $TAG_NAME == *"mongodb-node-3"* ]]; then
    sudo mkdir -p /opt/backup/data
    sudo mkdir -p /opt/backup/script
    echo "$backup_script" | sudo tee /opt/backup/script/backup_script.sh
    chmod +x /opt/backup/script/backup_script.sh
    CRON_JOB="30 0 * * * /opt/backup/script/backup_script.sh >> /opt/backup/script/backup_script.log 2>&1"
    # Add the cron job
    (crontab -l ; echo "$CRON_JOB") | crontab -
    # Set hostname for mongodb-3
    sleep 250
fi

sudo mongosh admin --tls --tlsCAFile /etc/mongodb/ssl/mongoCA.crt --tlsCertificateKeyFile /etc/mongodb/ssl/mongo.pem -u $MONGO_USER -p $MONGO_PASSWORD --host mongodb.node1.mrr.com <<EOF
rs.conf()
EOF

echo "------------------------------------------"
echo "MongoDB Setup completed successfully."
echo "------------------------------------------"

sudo reboot

