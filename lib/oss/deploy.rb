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
  end

  def client
    @client ||= Aliyun::OSS::Client.new(
      endpoint: endpoint,
      access_key_id: access_key_id,
      access_key_secret: access_key_secret
    )
  end

  def bucket
    puts bucket_name
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
        remote,
        :file => remote_path.call(object),
        :metas => get_metas(expired_in)
      )
    end
  end

  # 计算缓存头部（默认为1年）
  def get_metas(days)
    today = Date.today
    expire_date = Date.today + days.to_i
    expired = expire_date.to_time.getgm
    max_age = days.to_i * 24 * 60 * 60
    return {
      "Cache-Control": "max-age=" + max_age.to_s,
      "Expires": expired
    }
  end
end