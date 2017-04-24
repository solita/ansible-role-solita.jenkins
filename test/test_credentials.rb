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
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: foo's desc
          xyz:
            username: xyzuser
            password: xyzpass
            description: xyz's desc
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
            description: foo's desc
          bar:
            username: baruser
            password: barpass
            description: bar's desc
      roles:
        - solita.jenkins
    EOF
    # Foo and xyz should remain present, and bar should be added.
    login_as 'solita_jenkins'
    assert_equal ["foouser/****** (foo's desc)",
                  "baruser/****** (bar's desc)",
                  "xyzuser/****** (xyz's desc)",
                  ].to_set, list_credentials
  end

  # New SSH key credentials are added if they are missing.
  def test_add_ssh_key
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_absent_credentials:
          - foo
          - bar
          - xyz
      roles:
        - solita.jenkins
    EOF
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            private_key: fookey
            passphrase: foopass
            description: foo's desc
      roles:
        - solita.jenkins
    EOF
    login_as 'solita_jenkins'
    assert_equal ["foouser (foo's desc)"].to_set, list_credentials
  end

  # Credentials listed in solita_jenkins_absent_credentials are removed if they
  # are present. Unlisted credentials are not modified.
  def test_remove_credentials
    # Initially credentials foo and xyz are present, bar is absent.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: foo's desc
          xyz:
            username: xyzuser
            password: xyzpass
            description: xyz's desc
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
    assert_equal ["xyzuser/****** (xyz's desc)"].to_set, list_credentials
  end

  # Existing credentials can be changed.
  def test_change_credentials
    # Foo is a password, bar is an SSH key.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
          bar:
            username: baruser
            private_key: barkey
        solita_jenkins_absent_credentials:
          - xyz
      roles:
        - solita.jenkins
    EOF
    # Change foo into an SSH key and bar into a password.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            private_key: fookey
          bar:
            username: baruser
            password: barpass
        solita_jenkins_absent_credentials:
          - xyz
      roles:
        - solita.jenkins
    EOF
    login_as 'solita_jenkins'
    assert_equal ['foouser', 'baruser/******'].to_set, list_credentials
  end

  # Special character's are escaped correctly.
  def test_special_characters
    # Foo is a password, bar is an SSH key.
    ansible_playbook '--tags solita_jenkins_credentials', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_credentials:
          foo:
            username: foouser
            password: foopass
            description: "\\\\foo \\"' ${bar}"
        solita_jenkins_absent_credentials:
          - bar
          - xyz
      roles:
        - solita.jenkins
    EOF
    login_as 'solita_jenkins'
    assert_equal ["foouser/****** (\\foo \"' ${bar})",
                  ].to_set, list_credentials
  end

end
