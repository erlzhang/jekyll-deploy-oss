require_relative "./oss/deploy.rb"

class JekyllDeployOss < Jekyll::Command
  class << self
    def init_with_program(prog)
      prog.command(:deploy) do |c|
        c.syntax "deploy [options]"
        c.description 'Deploy Jekyll site to Aliyun OSS.'
        c.alias :d

        add_options(c)

        c.action do |args, options|
          deploy_site(options)
        end
      end
    end

    def deploy_site(options)
      options = Jekyll.configuration({
        :deploy => options.merge!(ENV)
      })

      params = options["deploy"]
      return unless validate_options(params)

      remote_path = Proc.new do |path|
        object = path.sub(options["destination"], "")
        object[0] === "/" ? object.sub("/", "") : object
      end

      paths = get_paths(options)
      Deploy.new(params).upload(paths, remote_path)
    end

    def get_paths(options)
      dir = options["destination"]
      params = options["deploy"]
      paths = []
      if params["paths"]
        params["paths"].each do |path|
          paths << File.join(dir, path)
        end
      else
        paths << dir
      end
      paths
    end

    def add_options(cmd)
      cmd.option "destination", "-d", "--destination DESTINATION",
                 "The files in DESTINATION will be uploaded."
      cmd.option "OSS_ID", "--id OSS_ID"
      cmd.option "OSS_SECRET", "--secret OSS_SECRET"
      cmd.option "endpoint", "--endpoint ENDPOINT"
      cmd.option "bucket_name", "--bucket BUCKET"
      cmd.option "paths", "--paths PATH[,PATH2,...]",
                 Array, "The specific files(or folders) will be uploaded."
      cmd.option "skip_exist", "--skipped", "Skip the exisiting files."
      cmd.option "expired_in", "--expired DAYS", Integer,
                 "Set the files caches expireds in DAYS days."
    end

    def required_options
      ["OSS_ID", "OSS_SECRET", "endpoint", "bucket_name"]
    end

    def validate_options(options)
      unless options
        Jekyll.logger.error "ERROR:", "Missing deploy configs!"
        return false
      end

      required_options.each do |key|
        unless options[key]
          Jekyll.logger.error "ERROR:", "#{key} is required to build!"
          return false
        end
      end

      true
    end
  end
end