require 'aliyun/oss'
require 'find'

class Deploy
  attr_reader :access_key_id, :access_key_secret, :endpoint, :bucket_name

  def initialize(id, secret, params = {})
    @access_key_id     = id
    @access_key_secret = secret
    @endpoint          = params[:endpoint]
    @bucket_name       = params[:bucket_name]
    @params            = params
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
        Find.find(path) { |file| files << file if File.file?(file) }
      end
    end
    files.compact
  end

  def upload(paths)
    objects = local_objects(paths)
    puts objects
    objects.each do |object|
      @bucket.put_object(
        remote_path(object),
        :file => object,
        :metas => get_metas(params["expired_in"])
      )
    end
  end

  # 计算缓存头部（默认为1年）
  def get_metas(days = 365)
    today = Date.today
    expire_date = today + days
    expired = expire_date.to_time.getgm
    max_age = days * 24 * 60 * 60
    return {
      "Cache-Control": "max-age=" + max_age,
      "Expires": expired
    }
  end
end