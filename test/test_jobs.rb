require 'test_helper'

class TestJobs < Minitest::Test

  include TestHelper

  # Jobs are created/modified/deleted to match jobs/Main.groovy.
  def test_jobs
    # Disable security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF
    # Configure Jenkins with only one, randomly named, job.
    job_name = (0...8).map { (65 + rand(26)).chr }.join
    ansible_playbook '--tags solita_jenkins_jobs', <<-EOF, :jobs => { "Main.groovy" => <<-EOF2 }
    ---
    - hosts: vagrant
      roles:
        - solita.jenkins
    EOF
    job('#{job_name}') {
    }
    EOF2
    # Only the configured job should be present.
    assert_equal [job_name].to_set, list_jobs
  end

  # Jobs are read from all Groovy files.
  def test_multiple_groovy_files
    # Disable security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF
    # Create jobs from two Groovy files.
    ansible_playbook '--tags solita_jenkins_jobs', <<-EOF, :jobs => { "First.groovy" => <<-EOF2, "Second.groovy" => <<-EOF3 }
    ---
    - hosts: vagrant
      roles:
        - solita.jenkins
    EOF
    job('job1') {
    }
    EOF2
    job('job2') {
    }
    EOF3
    # Jobs defined in each Groovy file should be present.
    assert_equal ['job1', 'job2'].to_set, list_jobs
  end

end
