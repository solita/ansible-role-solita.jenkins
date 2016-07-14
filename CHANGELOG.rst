=========
Changelog
=========

----------
Git master
----------

- Fix permission issues due to missing ``become`` options.

- Try to work around ``inventory_dir`` being ``None`` (`#14`_).

- Upgrade ``geerlingguy.jenkins`` to ``2.2.0``.

- Create an SSH key pair for ``jenkins`` and always run Jenkins CLI as
  ``jenkins``. This way all Ansible users have access to the key added to the
  ``solita_jenkins`` Jenkins user.

--------------------------
Version 1.0.2 (2016-07-03)
--------------------------

- Fix issues with ``become_user: jenkins`` on Ansible 2.1.

--------------------------
Version 1.0.1 (2016-07-01)
--------------------------

- Prevent Jenkins restart when variable ``solita_jenkins_restart`` is set to
  ``no``.

--------------------------
Version 1.0.0 (2016-06-29)
--------------------------

- Add support for Jenkins 2.

..
_#14: https://github.com/solita/ansible-role-solita.jenkins/issues/14
