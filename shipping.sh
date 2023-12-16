#!.bin/bash

ID=$(id -u) #getting user ID

R="\e[31m" # these are color codes
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating variables 
MYSQL_HOST=mysql.projoy.store
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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "java installation"

id roboshop # this one loosk for if user in this case roboshop already exsit
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "creating user roboshop"
else
    echo -e "roboshop user already exsit $Y SKIPPING$N"
fi

mkdir -p /app &>> $LOGFILE #-p check if dirctory exit or not, if yes skips creatin, if not create directory
VALIDATE $? "Creating App Directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloding shipping.zip"

cd /app &>> $LOGFILE
VALIDATE $? "getting into app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE # -o overwrite if unzipped file alteady exsist
VALIDATE $? "unziping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Changing name to shipping.jar"

cp /home/centos/roboshop-shell-practice/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Coping shipping.serice to systemd"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading Schema and giving RoboShop@1 as password"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting Shipping" 

netstat -lntp 