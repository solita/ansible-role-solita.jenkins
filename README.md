Role Name
=========

`solita.jenkins` is an Ansible role for Jenkins installations that are entirely under configuration management. It builds on top of [`geerlingguy.jenkins`](https://galaxy.ansible.com/detail#/role/440), adding support for [Jenkins Job DSL](https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin) and configuring Jenkins.

Supported operating systems
---------------------------

The role is tested on Ubuntu 14.04 LTS (Trusty Thar), but it should work on all operating systems supported by [`geerlingguy.jenkins`](https://galaxy.ansible.com/detail#/role/440).

Role Variables
--------------

Dependencies
------------

- [`geerlingguy.jenkins`](https://galaxy.ansible.com/detail#/role/440)

Example Playbook
----------------

    - hosts: servers
      roles:
         - role: solita.jenkins

License
-------

MIT

Author Information
------------------

Copyright (c) 2015 Solita
