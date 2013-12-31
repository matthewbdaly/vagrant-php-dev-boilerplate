Vagrant PHP Dev Boilerplate
===========================

A boilerplate Vagrant configuration for PHP development. Just download it and use it as a starting point for your own projects. You'll find the VM at http://192.168.56.101.

It includes a full LAMP stack, as well as PHPMyAdmin and Composer.

It also includes Webgrind at http://192.168.56.101/webgrind/, XHProf at http://192.168.56.101/xhprof/, and Mailcatcher at http://192.168.56.101:1080/.

In addition, if you want to use MongoDB as your database instead of MySQL, there's an alternative bootstrap script at `mongobootstrap.sh` that sets up MongoDB instead of MySQL. To use it, replace the reference to `bootstrap.sh` in `Vagrantfile` with `mongobootstrap.sh`
