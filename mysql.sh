#!.bin/bash

ID=$(id -u) #getting user ID

R="\e[31m" # these are color codes
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating variables 
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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabling Current MySQL version" 

cp /home/centos/roboshop-shell-practice/mysql.repo  /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Coping MySQL5.7 repo file"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Change the default root password to RoboShop@1"

mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "New Password"

netstat -lntp 