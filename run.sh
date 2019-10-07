#!/bin/bash
docker stop dev_moodle
docker rm dev_moodle
docker run -d --name "dev_moodle" -p "80:80" -p "443:443" -v "/var/www:/var/www"  oswmilanez/dev_moodle:latest

