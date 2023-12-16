#!.bin/bash

ID=$(id -u) #getting user ID

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" #$0 is to get script file name

echo "script started excicuting at $TIMESTAMP" &>> $LOGFILE # &=both sucess and failure >>appending 

VALIDATE(){

    if [ $1 -ne 0 ] #l$1 takes valuve from $? VALIDATE command from line 43  
    then
        echo -e "$2 ... $R FAILLED $N" #-e enables $ functions in this case color coding
        exit 1
    else 
        echo -e "$2 ...$G SUCESSFUL $N " # &=both success and failure >>=appending, >= overwite content 
    fi
}

if [ $ID -ne 0 ] #checking if user as root acess or permisions to intall the packages 
then
    echo -e "$R Use Root Acess $N" #if does not have permission then asks to get permission
    exit 1 #since cany install exiting the program
else 
    echo -e "$G Proceding with Installation $N" # if had all permmsions it will proceeed to instaltion of packages
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Intalling redis repo"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling redis 6.2 package"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Intalling redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "Remote acess for redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"

netstat -lntp 