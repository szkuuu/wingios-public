# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'WingUser' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WingUser
  pod 'SwiftLint'
  pod 'RxSwift', '6.2.0'
  pod 'RxCocoa', '6.2.0'
  pod 'RxGesture'
  pod 'Action'
  pod 'NSObject+Rx'
  pod 'Moya/RxSwift', '~> 15.0'
  pod 'RxKeyboard'
  pod 'SnapKit', '~> 5.0.0'
  pod 'PinLayout'
  pod 'Then'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'Atributika'
  pod 'SwiftDate', '~> 6.0'
  pod 'EFCountingLabel'
  pod 'PanModal'
  pod 'Carte'
  pod 'RealmSwift', '~> 10'
  pod 'Kingfisher', '~> 7.0'
  pod 'Socket.IO-Client-Swift', '~> 16.0'

  target 'WingUserTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '6.2.0'
    pod 'RxTest', '6.2.0'
    pod 'RxNimble'
    pod 'Quick'
    pod 'Nimble'
  end

  target 'WingUserUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
