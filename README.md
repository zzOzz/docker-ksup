# docker-ksup
Docker Image for KSUP container



##build

###build war with extensions
cd java;mvn clean package;cd ..

###build image
docker-compose build

##startup
docker-compose up
