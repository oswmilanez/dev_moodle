The purpose of this project is to help PHP application profiling,
Mainly focused on Moodle but can be used in any PHP application.

1 - Put on the hosts of the machine the following.
127.0.0.1   local.xhprof

2 - Put the following include in PHP you want to profile.
require('/var/xhgui/external/header.php');

Sample run docker run -d --name "dev_moodle" -p "80:80" -p "443:443" -v "/var/www:/var/www" oswmilanez/dev_moodle:latest

Local aplication https://localhost/

Local xhprof https://local.xhprof/

Hosts 127.0.0.1 local.xhprof

