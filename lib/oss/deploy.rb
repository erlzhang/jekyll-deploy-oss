require 'aliyun/oss'
require 'find'
require 'date'
require 'jekyll'

class Deploy
  attr_reader :access_key_id, :access_key_secret, :endpoint, :bucket_name, :expired_in, :skip_exist

  def initialize(params = {})
    @access_key_id     = params["OSS_ID"]
    @access_key_secret = params["OSS_SECRET"]
    @endpoint          = params["endpoint"]
    @bucket_name       = params["bucket_name"]
    @expired_in        = params["expired_in"] || 365
    @skip_exist        = params["skip_exist"]
  end

  def client
    @client ||= Aliyun::OSS::Client.new(
      endpoint: endpoint,
      access_key_id: access_key_id,
      access_key_secret: access_key_secret
    )
  end

  def bucket
    @bucket ||= client.get_bucket(bucket_name)
  end

  # 文件列表
  def objects
    bucket.list_objects
  end

  def remote_objects
    objects.map(&:key)
  end

  def local_objects(paths)
    files = []
    paths.each do |path|
      if File.file?(path)
        files << path
      elsif File.directory?(path)
        Find.find(path) do |file|
          files << file if File.file?(file)
        end
      end
    end
    files.compact
  end

  def upload(paths, remote_path)
    objects = local_objects(paths)
    objects.each do |object|
      remote = remote_path.call(object)
      if skip_exist and remote_objects.include?(remote)
        Jekyll.logger.info "Skip exist file: #{remote}"
        next
      end
      Jekyll.logger.info "Upload file: #{remote}"
      bucket.put_object(
        remote,
        :file => object,
        :headers => {
          "Cache-Control": cache_control,
          "Expires": expires
        }
      )
    end
  end

  def cache_control
    max_age = expired_in.to_i * 24 * 60 * 60
    "max-age=" + max_age.to_s
  end

  def expires
    expire_date = Date.today + expired_in.to_i
    expire_date.to_time.getgm
  end
end