Pod::Spec.new do |s|
  s.name = "RxStoreKit"
  s.version = "0.1.0"
  s.summary = "A short description of RxStoreKit."

  s.description = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage = "https://github.com/qiuncheng/RxStoreKit"
  s.license = {:type => "MIT", :file => "LICENSE"}
  s.author = {"qiuncheng" => "qiuncheng@gmail.com"}
  s.source = {:git => "https://github.com/qiuncheng/RxStoreKit.git", :tag => s.version.to_s}

  s.ios.deployment_target = "8.0"

  s.source_files = "RxStoreKit/Classes/**/*"

  s.dependency "RxSwift"
  s.dependency "RxCocoa"
end
