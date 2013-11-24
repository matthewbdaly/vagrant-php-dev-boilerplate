Vagrant PHP Dev Boilerplate
===========================

A boilerplate Vagrant configuration for PHP development. Just download it and use it as a starting point for your own projects. You'll find the VM at http://192.168.56.101.

It includes a full LAMP stack, as well as PHPMyAdmin, and `msmtp` to enable you to use a Gmail account for testing email functionality. Don't forget to set the email configuration in `bootstrap.sh`.

In addition, if you want to use MongoDB as your database instead of MySQL, there's an alternative bootstrap script at `mongobootstrap.sh` that sets up MongoDB instead of MySQL. To use it, replace the reference to `bootstrap.sh` in `Vagrantfile` with `mongobootstrap.sh`
