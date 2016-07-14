require 'test_helper'

class TestSecurity < Minitest::Test

  include TestHelper

  # When solita_jenkins_security_realm is set to "none", Jenkins is unsecured.
  def test_realm_none
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF
    open_dashboard
    assert can_manage_jenkins?
  end

  # When solita_jenkins_security_realm is set to "jenkins", Jenkins is secured.
  def test_realm_jenkins
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
      roles:
        - solita.jenkins
    EOF
    assert_forbidden { open_dashboard }
  end

  # It's an error to use user variables when solita_jenkins_security_realm is
  # not jenkins.
  def test_users_with_wrong_security_realm
    assert_raises do
      ansible_playbook '--tags solita_jenkins_security', <<-EOF, :silent => true
      ---
      - hosts: vagrant
        vars:
          solita_jenkins_security_realm: none
          solita_jenkins_users:
            - foo
        roles:
          - solita.jenkins
      EOF
    end
  end

  # Users listed in solita_jenkins_users are added if they are missing.
  # Unlisted users are not modified.
  def test_add_users
    # Initially users foo and xyz are present, bar is absent.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
        solita_jenkins_users:
          - foo
          - xyz
        solita_jenkins_absent_users:
          - bar
      roles:
        - solita.jenkins
    EOF
    # Ensure foo and bar are present.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
        solita_jenkins_users:
          - foo
          - bar
      roles:
        - solita.jenkins
    EOF
    # Foo and xyz should remain present, and bar should be added.
    login_as 'solita_jenkins'
    assert_equal ['admin', 'foo', 'xyz', 'bar'].to_set, list_users
  end

  # Users listed in solita_jenkins_absent_users are removed if they are
  # present. Unlisted users are not modified.
  def test_remove_users
    # Initially users foo and xyz are present, bar is absent.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
        solita_jenkins_users:
          - foo
          - xyz
        solita_jenkins_absent_users:
          - bar
      roles:
        - solita.jenkins
    EOF
    # Ensure foo and bar are absent.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
        solita_jenkins_absent_users:
          - foo
          - bar
      roles:
        - solita.jenkins
    EOF
    # Xyz should remain present, bar should remain absent, and foo should be
    # removed.
    login_as 'solita_jenkins'
    assert_equal ['admin', 'xyz'].to_set, list_users
  end

  # solita_jenkins password doesn't change even if a new default password is
  # generated.
  def test_keep_solita_jenkins_password
    # Disable security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF

    # Set "foo" as the default password.
    system 'echo foo >environments/vagrant/solita_jenkins_default_password/solita_jenkins'

    # Enable security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
      roles:
        - solita.jenkins
    EOF
    system 'sudo cat /var/lib/jenkins/init.groovy.d/solita_jenkins_security_realm.groovy >/tmp/realm1.groovy'

    # Set "bar" as the default password.
    system 'echo bar >environments/vagrant/solita_jenkins_default_password/solita_jenkins'

    # Re-configure security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
      roles:
        - solita.jenkins
    EOF
    system 'sudo cat /var/lib/jenkins/init.groovy.d/solita_jenkins_security_realm.groovy >/tmp/realm2.groovy'

    # The security configuration should not change.
    assert_equal File.read('/tmp/realm1.groovy'), File.read('/tmp/realm2.groovy')
  end

end
