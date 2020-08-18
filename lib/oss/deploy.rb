require 'aliyun/oss'
require 'find'

class Deploy
  attr_reader :access_key_id, :access_key_secret, :endpoint, :bucket_name

  def initialize(id, secret, params = {})
    @access_key_id     = id
    @access_key_secret = secret
    @endpoint          = params[:endpoint]
    @bucket_name       = params[:bucket_name]
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

  def upload(paths, files)
    objects = local_objects(paths, files)
  end
end