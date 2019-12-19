==============
solita.jenkins
==============

Ansible role: A Jenkins installation completely configured with Ansible.

-------------
Documentation
-------------

`Reference <http://solita-cd.readthedocs.org/en/latest/solita.jenkins.html>`_

-------------
Development
-------------

Setup a test environment by running ``vagrant up`` in test directory.
Execute ``vagrant ssh -c rake`` to run unit tests.

-------------
OpenJDK 11
-------------
This role has dependency on `geerlingguy.java <https://github.com/geerlingguy/ansible-role-java>`_.

`geerlingguy.java <https://github.com/geerlingguy/ansible-role-java>`_ supports OpenJDK 11 installation out of the box with, by specifying `java_packages` variable in inventory / playbook / extra vars like this:

RedHat/Centos:

.. code-block:: yaml
  
    vars:
      java_packages: 
        - java-11-openjdk


Debian/Ubuntu:

.. code-block:: yaml
    
    vars:
      java_packages:
        - openjdk-11-jdk


------------
Contributors
------------

- `Timo Mihaljov <https://github.com/noidi>`_
- `Kimmo Koskinen <https://github.com/viesti>`_
- `Heikki Hokkanen <https://github.com/hoxu>`_
- `Jukka Siivonen <https://github.com/jukkasi>`_
- `bery <https://github.com/bery>`_
- `Panu Kalliokoski <https://github.com/pkalliok>`_
- `Juha Jokimäki <https://github.com/jokimaki>`_
- `Aleksei Hodunkov <https://github.com/0leksei>`_
