require 'open3'
require 'minitest/focus'

module TestHelper

  def unindent(s)
    indent = s[/[ \t]*/]
    s.gsub(/^#{indent}/, '')
  end

  def ansible_playbook(args, contents)
    p = Tempfile.new('playbook.yml', '.')
    begin
      p.write(unindent(contents))
      p.close

      stdout, stderr, status = Open3.capture3("ansible-playbook -i environments/vagrant/inventory #{args} #{p.path}")

      unless status.success? then
        puts stdout
        puts stderr
        flunk('ansible-playbook failed!')
      end
    ensure
      p.unlink
    end
  end

end
