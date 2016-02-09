require 'test_helper'

class TestJobs < Minitest::Test

  include TestHelper

  # Jobs are created/modified/deleted to match jobs/main.groovy.
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
    ansible_playbook '--tags solita_jenkins_jobs', <<-EOF, :job_dsl => <<-EOF2
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

end
