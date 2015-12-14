gem 'minitest'
require 'minitest/autorun'
require 'mechanize'
require 'test_helper'

class TestSecurity < Minitest::Test

  include TestHelper

  def setup
    @agent = Mechanize.new { |a| a.log = Logger.new('/tmp/mechanize.log') }
  end

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

  # When solita_jenkins_security_realm is undefined, an unsecured Jenkins
  # remains unsecured.
  def test_realm_undefined_unsecured
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      roles:
        - solita.jenkins
    EOF
    open_dashboard
    assert can_manage_jenkins?
  end

  # When solita_jenkins_security_realm is undefined, a secured Jenkins remains
  # secured.
  def test_realm_undefined_secured
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: jenkins
      roles:
        - solita.jenkins
    EOF
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      roles:
        - solita.jenkins
    EOF
    assert_forbidden { open_dashboard }
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
    assert_equal ['foo', 'xyz', 'bar'].to_set, list_users
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
    assert_equal ['xyz'].to_set, list_users
  end

  def open_dashboard
    @agent.get('http://localhost:8080')
  end

  def can_manage_jenkins?
    not @agent.page.link_with(:text => 'Manage Jenkins').nil?
  end

  def assert_forbidden(&block)
    begin
      yield
      flunk 'Expected 403, got 200/301/302'
    rescue Mechanize::ResponseCodeError => e
      assert_equal "403", e.response_code
    end
  end

  def login_as(username)
    page = @agent.get('http://localhost:8080/login')
    form = page.form('login')
    form.j_username = username
    form.j_password = File.read("environments/vagrant/solita_jenkins_default_password/#{username}").strip
    @agent.submit(form, form.buttons.first)
  end

  def list_users
    @agent.get('http://localhost:8080/securityRealm')\
      .search('//table[@id="people"]//tr/td[2]//*')\
      .map { |n| n.text }\
      .to_set\
      .delete('solita_jenkins')
  end

end
