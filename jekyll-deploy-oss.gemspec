Gem::Specification.new do |spec|
  spec.name          = "jekyll-deploy-oss"
  spec.version       = "0.1.0"
  spec.authors       = ["erlzhang"]
  spec.email         = ["zhangshiyu1992@hotmail.com"]
  spec.summary       = "Deploy your Jekyll site to Aliyun OSS."
  spec.description   = "Deploy your Jekyll site to Aliyun OSS."
  spec.homepage      = "https://github.com/erlzhang/jekyll-deploy-oss"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"

  spec.add_runtime_dependency "aliyun-sdk"
end