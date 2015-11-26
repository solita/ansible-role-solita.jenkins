==============
solita.jenkins
==============

A Jenkins installation completely configured with Ansible. The role builds on top of geerlingguy.jenkins_, adding support for `Jenkins Job DSL`_ and configuring Jenkins.

The role is tested on Ubuntu 14.04 LTS (Trusty Thar), but it should work on all operating systems supported by geerlingguy.jenkins_.

.. note::

    Currently the role requires a `main.groovy`_ file. This file will be made optional and configurable in a future version of the role.

-----
Files
-----

.. _the default password file:

<inventory_dir>/solita.jenkins_default_password/<username>
==========================================================

The contents of this file will be used as the default password when creating the user <username>. If the file is not present, a file containing a random password is created.

.. _main.groovy:

<playbook_dir>/job-dsl/main.groovy
==================================

Currently this file must exist and contain a valid `Job DSL` script. The script will be executed when the role is applied.

<playbook_dir>/job-dsl/\*.groovy
================================

These files are copied along `main.groovy`_. They may contain additional code imported into main.groovy.

---------
Variables
---------

solita_jenkins_plugins
======================

The plugin IDs of additional Jenkins plugins to install. You can see a plugin's plugin ID on its `wiki page <https://wiki.jenkins-ci.org/display/JENKINS/Plugins>`_.

This role depends on the the `Job DSL plugin`_ and always installs it.

Required
    no

Default
    ``[]``

solita_jenkins_security_realm
=============================

Changes the way Jenkins users are authenticated and authorized.

Required
    no

Default
    undefined

Choices
    undefined
        Leave Jenkins' security settings unchanged.

    ``'none'``
        Disable security.

    ``'jenkins'``
        Enable security, authentication against Jenkins' own user database, and matrix-based authorization.

solita_jenkins_absent_users
===========================

A list of users that must *not* exist in the Jenkins installation.

This variable has no effect unless `solita_jenkins_security_realm`_ is set to ``'jenkins'``.

Required
    no

Default
    ``[]``

See also
    `solita_jenkins_users (var)`_

.. _solita_jenkins_users (var):

solita_jenkins_users
====================

A list of users that must exist in the Jenkins installation. Currently only administrator users are supported. The new users' default passwords will be read from / written to `the default password file`_.

This variable has no effect unless `solita_jenkins_security_realm`_ is set to ``'jenkins'``.

Required
    no

Default
    ``[]``

See also
    `solita_jenkins_absent_users`_

----
Tags
----

solita_jenkins_users
====================

Change security settings and add/remove users.

solita_jenkins_job_dsl
======================

Update jobs by running the latest version of `main.groovy`_.

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
.. _Job DSL: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
.. _Job DSL plugin: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
.. _Jenkins Job DSL: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
