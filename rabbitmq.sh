#!/bin/bash

ID=$(id -u) #getting user ID

R="\e[31m" # these are color codes
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating variables 
MONGODB_HOST=mongodb.projoy.store
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" #$0 is to get script file name

echo "script started excicuting at $TIMESTAMP" &>> $LOGFILE # &=both success and failure >>=appending, >= overwite content 

VALIDATE(){

    if [ $1 -ne 0 ] # $1 takes valuve from $? VALIDATE command from line 37,  
    then
        echo -e "$2 ... $R FAILLED $N" # -e enables $ functions in this case color coding
        exit 1
    else 
        echo -e "$2 ...$G SUCESSFUL $N " # $2 takes 2ng arrgument from VALIDATE command 
    fi
}

if [ $ID -ne 0 ] #checking if user as root acess or permisions to intall the packages 
then
    echo -e "$R Use Root Acess $N" #if does not have permission then asks to get permission
    exit 1 #since cany install exiting the program
else 
    echo -e "$G Proceding with Installation $N" # if had all permmsions it will proceeed to instaltion of packages
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configuring YUM Repos from the script provided by vendo"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configuring YUM Repos for RabbitMQ."

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "Starting RabbitMQ Service"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "Creating user and password for RabbitMQ"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE
VALIDATE $? "Giving acess to user"

netstat -lntp 