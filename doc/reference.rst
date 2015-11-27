==============
solita.jenkins
==============

A Jenkins installation completely configured with Ansible. This role builds on top of geerlingguy.jenkins_, adding support for configuring Jenkins and defining jobs and views with a `Job DSL`_ script.

This role is tested on Ubuntu 14.04 LTS (Trusty Thar), but it should work on all operating systems supported by geerlingguy.jenkins_.

In its default settings, this role does not change Jenkins' configuration in any way, so it is safe to run on a server with an existing Jenkins installation.

.. contents::
   :backlinks: none
   :local:

------------
Installation
------------

You can install this role and its dependencies with ansible-galaxy_:

.. highlight:: sh
::

    ansible-galaxy install -p path/to/your/roles https://github.com/solita/ansible-role-solita.jenkins.git

Once installed, you should be able to use the role in your playbooks:

.. highlight:: yaml
::

    # playbook.yml
    ---
    - hosts: servers
      roles:
         - solita.jenkins

-------
Plugins
-------

.. _solita_jenkins_plugins:

To add plugins to your Jenkins installation, list their plugin IDs in the variable ``solita_jenkins_plugins``. You can find a plugin's plugin ID on its `wiki page <https://wiki.jenkins-ci.org/display/JENKINS/Plugins>`_.

.. note ::

    This role depends on the the `Job DSL plugin`_ and always installs it.

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

Examples
========

Enable security, add users ``alice`` and ``bob``, and remove user ``eve``:

.. highlight:: yaml
::

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

You can limit the role application to security settings and user management with the tag ``solita_jenkins_security``:

.. highlight:: sh
::

    ansible-playbook -i environments/vagrant/inventory playbook.yml --tags solita_jenkins_security

--------------
Jobs and Views
--------------

You can define jobs and views with a `Job DSL`_ script. The role looks for scripts in the directory ``job-dsl`` next to your playbook and runs the script called ``main.groovy``, which can import the other scripts in the directory.

To change the Job DSL script directory, set the variable ``solita_jenkins_job_dsl_dir``.

Examples
========

If you create your script in the default location, no configuration is needed:

.. highlight:: groovy
::

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

If you want to place your scripts somewhere else, set the variable ``solita_jenkins_job_dsl_dir``:

.. highlight:: yaml
::

    # playbook.yml
    ---
    - hosts: servers
      vars:
        solita_jenkins_job_dsl_dir: "{{ playbook_dir }}/files/jenkins/jobs"
      roles:
         - solita.jenkins

You can limit the role application to job and view updates with the tag ``solita_jenkins_jobs``:

.. highlight:: sh
::

    ansible-playbook -i environments/vagrant/inventory playbook.yml --tags solita_jenkins_jobs

.. ------------
.. Dependencies
.. ------------

.. -  `geerlingguy.jenkins`_ 
..     - You'll need to use `this patched version <https://github.com/noidi/ansible-role-jenkins/tree/await-secured-jenkins>`_ until geerlingguy.jenkins adds `support for secured Jenkins installations <https://github.com/geerlingguy/ansible-role-jenkins/pull/31>`_.


.. _geerlingguy.jenkins: https://galaxy.ansible.com/detail#/role/440
.. _ansible-galaxy: http://docs.ansible.com/ansible/galaxy.html#the-ansible-galaxy-command-line-tool
.. _Job DSL: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
.. _Job DSL plugin: https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin
