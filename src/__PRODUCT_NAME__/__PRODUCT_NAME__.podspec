# vi: ft=ruby

Pod::Spec.new do |s|
  s.name = '__PRODUCT_NAME__'
  s.version = '1.0.0'
  s.summary = '__PRODUCT_NAME__ Library'

  s.description = <<-DESC
  __PRODUCT_NAME__ Library for iOS
  DESC

  s.homepage = 'https://www.rocketinsights.com'

  s.author = '__AUTHOR__'

  # TODO: Change the GIT URL to match the project's home.
  s.source = { :git => 'https://github.com/Organization/Repo.git', :tag => '#{s.version}' }
  s.license = { :type => 'MIT' }

  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/__PRODUCT_NAME__/**/*.swift'
  s.resources = 'Sources/__PRODUCT_NAME__/**/*.{storyboard,xcassets, strings,imageset,png}'

  # TODO: Add dependencies
  # NOTE: The __PRODUCT_NAME__ target in the Podfile must include the same dependencies.
  # s.dependency 'Name', '~> Version'
end

