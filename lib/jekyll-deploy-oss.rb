require_relative "./oss/deploy.rb"

class JekyllDeployOss < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy [options]"
        c.description 'Deploy Jekyll site to Aliyun OSS.'
        c.alias :d

        c.option 'dest', '-d DEST', 'Where the site should go.'

        c.action do |args, options|
          #Jekyll::Site.new_site_at(options['dest'])
        end
      end
    end
  end
end