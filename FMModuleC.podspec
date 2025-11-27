Pod::Spec.new do |s|
  s.name             = 'FMModuleC'
  s.version          = '0.0.2'
  s.summary          = '使用MVI+SwiftUI实现的业务C组件'
  
  s.homepage         = 'https://github.com/MrLfm/FMModuleC'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MrLfm' => 'lfm_1992@126.com' }
  s.source           = { :git => 'https://github.com/MrLfm/FMModuleC.git', :tag => s.version.to_s }

  s.ios.deployment_target = '17.0'
  s.swift_version = '5.0'

  s.source_files = 'FMModuleC/Classes/**/*'
  
  # 依赖组件
  s.dependency 'FMModuleCenter'
end
