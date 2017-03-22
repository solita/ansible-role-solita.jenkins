require 'test_helper'
require 'json'

class TestCredentials < Minitest::Test

  include TestHelper

  # New password credentials are added if they are missing. Unlisted
  # credentials are not modified.
  def test_add_password
    # Initially credentials foo and xyz are present, bar is absent.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: foodesc
          xyz:
            username: xyzuser
            password: xyzpass
            description: xyzdesc
        solita_jenkins_absent_credentials:
          - bar
      roles:
        - solita.jenkins
    EOF
    # Ensure foo and bar are present.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: foodesc
          bar:
            username: baruser
            password: barpass
            description: bardesc
      roles:
        - solita.jenkins
    EOF
    # Foo and xyz should remain present, and bar should be added.
    login_as 'solita_jenkins'
    assert_equal ['foouser/****** (foodesc)',
                  'baruser/****** (bardesc)',
                  'xyzuser/****** (xyzdesc)',
                  ].to_set, list_credentials
  end

  # Credentials listed in solita_jenkins_absent_credentials are removed if they
  # are present. Unlisted credentials are not modified.
  def test_remove_credentials
    # Initially credentials foo and xyz are present, bar is absent.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: foodesc
          xyz:
            username: xyzuser
            password: xyzpass
            description: xyzdesc
        solita_jenkins_absent_credentials:
          - bar
      roles:
        - solita.jenkins
    EOF
    # Ensure foo and bar are absent.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_absent_credentials:
          - foo
          - bar
      roles:
        - solita.jenkins
    EOF
    # Xyz should remain present, bar should remain absent, and foo should be
    # removed.
    login_as 'solita_jenkins'
    assert_equal ['xyzuser/****** (xyzdesc)'].to_set, list_credentials
  end

end
