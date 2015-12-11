gem 'minitest'
require 'minitest/autorun'
require 'mechanize'
require 'test_helper'

class TestSecurity < Minitest::Test

  include TestHelper

  def setup
    @agent = Mechanize.new
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

end
