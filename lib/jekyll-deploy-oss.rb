require_relative "./oss/deploy.rb"

class JekyllDeployOss < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy [options]"
        c.description 'Deploy Jekyll site to Aliyun OSS.'
        c.alias :d

        c.action do |args, options|
          deploy_site
        end
      end
    end

    def deploy_site
      @options = Jekyll.configuration
      @params = @options["deploy"] || {}
      deploy = Deploy.new(
        #ENV['OSS_ID'],
        #ENV["OSS_SECRET"],
        @params["OSS_ID"],
        @params["OSS_SECRET"],
        @params
      )
      remote_path = Proc.new do |path|
        object = path.sub(@options["destination"], "")
        object[0] === "/" ? object.sub("/", "") : object
      end

      deploy.upload(get_paths, remote_path)
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