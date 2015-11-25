==============
solita.jenkins
==============

A Jenkins installation completely configured with Ansible. The role builds on top of geerlingguy.jenkins_, adding support for `Jenkins Job DSL <https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin>`_ and configuring Jenkins.

The role is tested on Ubuntu 14.04 LTS (Trusty Thar), but it should work on all operating systems supported by geerlingguy.jenkins_.

---------
Variables
---------

``solita_jenkins_plugins``

   The plugin IDs of additional Jenkins plugins to install. You can see a plugin's plugin ID on its `wiki page <https://wiki.jenkins-ci.org/display/JENKINS/Plugins>`_.

This role depends on the ``job-dsl`` plugin and always installs it.

------------
Dependencies
------------

-  `geerlingguy.jenkins`_ 
    - You'll need to use `this patched version <https://github.com/noidi/ansible-role-jenkins/tree/await-secured-jenkins>`_ until geerlingguy.jenkins adds `support for secured Jenkins installations <https://github.com/geerlingguy/ansible-role-jenkins/pull/31>`_.

----------------
Example Playbook
----------------

::

    - hosts: servers
      sudo: yes
      vars:
        solita_jenkins_plugins:
          - timestamper
      roles:
         - solita.jenkins

.. _geerlingguy.jenkins: https://galaxy.ansible.com/detail#/role/440
