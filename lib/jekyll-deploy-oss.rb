require_relative "./oss/deploy.rb"

class JekyllDeployOss < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy [options]"
        c.description 'Deploy Jekyll site to Aliyun OSS.'
        c.alias :d

        c.action do |args, options|
          deploy
        end
      end
    end

    def deploy
      @options = Jekyll.configuration
      @params = @options["deploy"] || {}
      deploy = Deploy.new(
        ENV['OSS_ID'],
        ENV["OSS_SECRET"],
        @params
      )
      deploy.upload(get_paths)
    end

    def get_paths
      dir = @options["destination"]
      paths = []
      if @params["paths"]
        @params["paths"].each do |path|
          paths << File.join(dir, path)
        end
      else
        paths << dir
      end
      paths
    end
  end
end