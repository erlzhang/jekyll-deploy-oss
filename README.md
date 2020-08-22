# Jekyll Deploy OSS

The Jekyll command to deploy your Jekyll site to Aliyun OSS.

部署你的博客到阿里云的Jekyll命令。

## Installation

Add this line to your Jekyll site's `Gemfile`:

```ruby
gem "jekyll-deploy-oss"
```

Add `jekyll-deploy-oss` to your Jekyll site's `_config.yml`:

```yaml
plugins:
  - jekyll-deploy-oss
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-books

## Config

在部署之前，你需要在你博客的 `_config.yml`中新增一些配置：

```yml
deploy:
  # The endpoint of your Aliyun oss bucket
  endpoint: ""
  # The name of your Aliyun oss bucket
  bucket_name: ""
  # 如果遇到同名文件是否跳过，默认为覆盖；如果想要覆盖，需要设置为true
  skip_exist: false
  # 设置缓存过期时间，单位为天，默认为向365天
  expired_in: 3650
  # 指定（部署后目录下的）某些目录或文件上传
  paths:
    - test1
    - test.html
```

`endpoint` 和 `bucket_name` 为必填，其他选填。

此外上传到阿里云的`OSS_ID`和`OSS_SECRET`也是必要的，最好将他们加在环境变量中（这样最安全）。其次也可以作命令行的参数传入。

```sh
bundle exec jekyll deploy --id YOUR_OSS_ID --secret YOUR_OSS_SECRET
```

最不推荐的做法就是把他们加入配置中（当然如果你的配置文件不公开也没什么）。

```yml
deploy:
  OSS_ID: ""
  OSS_SECRET: ""
```
    
## Usage

在Jekyll构建成功后，执行以下命令，此插件会将`_site`（或其他你配置在`_confg.yml`中的`destination`构建目录）下的文件上传到你阿里云OSS的指定bucket。

```sh
bundle exec jekyll deploy
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/erlzhang/jekyll-deploy-oss. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The theme is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
