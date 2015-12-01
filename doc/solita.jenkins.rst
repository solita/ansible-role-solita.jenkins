==============
solita.jenkins
==============

A Jenkins installation completely configured with Ansible. This role builds on top of geerlingguy.jenkins_, adding support for configuring Jenkins and defining jobs and views with a `Job DSL`_ script.

This role is tested on Ubuntu 14.04 LTS (Trusty Thar), but it should work on all operating systems supported by `the upstream role`_.

In its default settings, this role does not change Jenkins' configuration in any way, so it's safe to apply it to a server with an existing, manually configured, Jenkins installation.

.. contents::
   :backlinks: none
   :local:

-------
Example
-------

.. highlight:: yaml

With this role and the `Job DSL plugin`_, your entire Jenkins configuration can be stored in text files that look something like this::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_plugins:
          - timestamper
          - git
        solita_jenkins_security_realm: jenkins
        solita_jenkins_users:
          - alice
          - bob
        solita_jenkins_absent_users:
          - eve
      roles:
         - solita.jenkins

.. highlight:: groovy

::

    // job-dsl/main.groovy
    job('DSL-Tutorial-1-Test') {
        scm {
            git('git://github.com/jgritman/aws-sdk-test.git')
        }
        triggers {
            scm('*/15 * * * *')
        }
        steps {
            maven('-e clean test')
        }
    }

------------
Installation
------------

.. highlight:: sh

You can install this role and its dependencies with ansible-galaxy_::

    ansible-galaxy install -p path/to/your/roles https://github.com/solita/ansible-role-solita.jenkins.git

-------
Plugins
-------

To add plugins to your Jenkins installation, list their plugin IDs in the variable ``solita_jenkins_plugins``. You can find a plugin's ID on its `wiki page <https://wiki.jenkins-ci.org/display/JENKINS/Plugins>`_.

.. note ::

    This role depends on the `Job DSL plugin`_ and always installs it.

Examples
========

Install the ``timestamper`` and ``git`` plugins:

.. highlight:: yaml

::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_plugins:
          - timestamper
          - git
      roles:
         - solita.jenkins

--------
Security
--------

A security realm means the method that Jenkins uses to authenticate users. To enable or disable authentication for your Jenkins installation, set the variable ``solita_jenkins_security_realm`` to one of the following values:

``none``
    Disables security.

``jenkins``
    Enables security, authentication against Jenkins' own user database, and matrix-based authorization.

User Management
===============

To add and remove users, add their usernames to the lists ``solita_jenkins_users`` and ``solita_jenkins_absent_users``, respectively.

When a new user is created, the user's default password will be read from the file ``solita_jenkins_default_password/<username>`` in the inventory directory. If the file does not exist, a file containing a random password is created. For example, if your inventory file is ``environments/vagrant/inventory`` and you add the user ``alice``, you can find their default password in the file ``environments/vagrant/solita_jenkins_default_password/alice``.

To limit role application to security settings and user management, use the tag ``solita_jenkins_security``.

Examples
========

.. highlight:: yaml

Enable security, add users ``alice`` and ``bob``, and remove user ``eve``::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_security_realm: jenkins
        solita_jenkins_users:
          - alice
          - bob
        solita_jenkins_absent_users:
          - eve
      roles:
         - solita.jenkins

Disable security::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_security_realm: none
      roles:
         - solita.jenkins

.. highlight:: sh

Only update security settings and users::

    ansible-playbook -i environments/vagrant/inventory playbook.yml --tags solita_jenkins_security

--------------
Jobs and Views
--------------

You can define jobs and views with a `Job DSL`_ script. The role looks for scripts in the directory ``job-dsl`` next to your playbook and runs the script called ``main.groovy``, which can import the other scripts in the directory.

To change the Job DSL script directory, set the variable ``solita_jenkins_job_dsl_dir``.

To limit role application to job and view updates, use the tag ``solita_jenkins_jobs``.

Examples
========

.. highlight:: groovy

If you create your script in the default location, no configuration is needed::

    // job-dsl/main.groovy
    job('my-new-job') {
        // ...
    }

.. highlight:: yaml

::

    # playbook.yml
    ---
    - hosts: servers
      roles:
         - solita.jenkins

.. highlight:: yaml

If you want to place your scripts somewhere else, set the variable ``solita_jenkins_job_dsl_dir``::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_job_dsl_dir: "{{ playbook_dir }}/files/jenkins/jobs"
      roles:
         - solita.jenkins

.. highlight:: sh

Only update jobs and views::

    ansible-playbook -i environments/vagrant/inventory playbook.yml --tags solita_jenkins_jobs

.. _geerlingguy.jenkins: https://galaxy.ansible.com/detail#/role/440
.. _the upstream role: geerlingguy.jenkins_
.. _ansible-galaxy: http://docs.ansible.com/ansible/galaxy.html#the-ansible-galaxy-command-line-tool
.. _Job DSL: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
.. _Job DSL plugin: `Job DSL`_
