require 'aliyun/oss'
require 'find'
require 'date'

class Deploy
  attr_reader :access_key_id, :access_key_secret, :endpoint, :bucket_name, :expired_in

  def initialize(id, secret, params = {})
    puts params
    @access_key_id     = id
    @access_key_secret = secret
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
    if !bucket
      puts "No valid Bucket!"
      return
    end

    objects = local_objects(paths)
    objects.each do |object|
      bucket.put_object(
        remote_path.call(object),
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