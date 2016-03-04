require 'test_helper'
require 'fileutils'

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
    ansible_playbook '--tags solita_jenkins_jobs', <<-EOF, :jobs => { "jobs/Main.groovy" => <<-EOF2 }
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

  # Jobs are read from all Groovy files in solita_job_dsl_dir.
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
    # Create jobs from two Groovy files in /tmp/jobdsl.
    FileUtils::rm_rf('/tmp/jobdsl')
    FileUtils::mkdir_p('/tmp/jobdsl')
    ansible_playbook '--tags solita_jenkins_jobs -e solita_jenkins_jobs_dir=/tmp/jobdsl', <<-EOF, :jobs => { "/tmp/jobdsl/First.groovy" => <<-EOF2, "/tmp/jobdsl/Second.groovy" => <<-EOF3 }
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

  # Job files ending in .groovy.j2 are filled in as Jinja templates before execution.
  def test_templates
    # Disable security.
    ansible_playbook '--tags solita_jenkins_security', <<-EOF
    ---
    - hosts: vagrant
      vars:
        solita_jenkins_security_realm: none
      roles:
        - solita.jenkins
    EOF
    FileUtils::rm_rf('/tmp/jobdsl')
    FileUtils::mkdir_p('/tmp/jobdsl/util')
    ansible_playbook '--tags solita_jenkins_jobs -e solita_jenkins_jobs_dir=/tmp/jobdsl -e job_name=foobar', <<-EOF, :jobs => { "/tmp/jobdsl/util/Ansible.groovy.j2" => <<-EOF2, "/tmp/jobdsl/Job.groovy" => <<-EOF3 }
    ---
    - hosts: vagrant
      roles:
        - solita.jenkins
    EOF
    package util;
    class Ansible {
      static final JOB_NAME = '{{ job_name }}';
    }
    EOF2
    import util.Ansible;
    job(Ansible.JOB_NAME) {
    }
    EOF3
    # Jobs defined in each Groovy file should be present.
    assert_equal ['foobar'].to_set, list_jobs
  end

end
