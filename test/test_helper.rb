require 'open3'
gem 'minitest'
require 'minitest/autorun'
require 'minitest/focus'
require 'mechanize'

module TestHelper

  def setup
    @agent = Mechanize.new { |a| a.log = Logger.new('/tmp/mechanize.log') }
  end

  def unindent(s)
    indent = s[/[ \t]*/]
    s.gsub(/^#{indent}/, '')
  end

  def ansible_playbook(args, contents, options = {})
    p = Tempfile.new('playbook.yml', '.')
    begin
      p.write(unindent(contents))
      p.close

      stdout, stderr, status = Open3.capture3("ansible-playbook -i environments/vagrant/inventory #{args} #{p.path}")

      unless status.success? then
        unless options[:silent] then
          puts stdout
          puts stderr
        end
        fail 'ansible-playbook failed!'
      end
    ensure
      p.unlink
    end
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
