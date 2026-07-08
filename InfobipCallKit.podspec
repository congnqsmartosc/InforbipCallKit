Pod::Spec.new do |s|
  s.name             = 'InfobipCallKit'
  s.version          = '1.0.0'
  s.summary          = 'Drop-in WebRTC calling UI wrapping the Infobip RTC iOS SDK.'
  s.description      = <<-DESC
    InfobipCallKit packages a complete UIKit calling experience — incoming/outgoing call screens,
    ringtone/ringback, in-call controls (mute, speaker, audio route), post-call feedback — on top
    of the Infobip RTC SDK. The host app supplies a WebRTC token via registerSubscriber and the
    framework presents and drives all call UI on its own overlay window. The public API mirrors the
    Android InfobipCallClient interface.
  DESC
  s.homepage         = 'https://github.com/congnqsmartosc/InforbipCallKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'congnq' => 'congnq@smartosc.com' }
  s.source           = { :git => 'https://github.com/congnqsmartosc/InforbipCallKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version         = '5.0'

  # Dynamic framework is REQUIRED: the Infobip RTC pod vendors a dynamic Swift/WebRTC binary,
  # so consumers must use `use_frameworks!`.
  s.static_framework = false

  s.default_subspec = 'Core'

  # Core: delegate + closure API. No RxSwift.
  s.subspec 'Core' do |c|
    c.source_files = 'Sources/InfobipCallKit/**/*.swift'
    c.exclude_files = 'Sources/InfobipCallKit/Rx/**/*'
    c.resource_bundles = {
      'InfobipCallKit' => [
        'Sources/InfobipCallKit/**/*.xib',
        'Resources/**/*.caf'
      ]
    }
    c.frameworks = 'UIKit', 'PushKit', 'AVFoundation', 'AudioToolbox'

    c.dependency 'InfobipRTC',   '~> 2.6.9'   # binary xcframework; bundles WebRTC on CocoaPods
    c.dependency 'SnapKit',      '~> 5.6'     # covers client 5.6.0–5.7.1
    c.dependency 'SDWebImage',   '~> 5.21'    # covers client 5.21.x
    c.dependency 'XCoordinator', '~> 2.2'     # resolves 2.2.1; pulls RxSwift ~> 6.1
  end

  # Optional Rx layer: adds `rx_activeSession: Observable<CallSession?>`.
  s.subspec 'Rx' do |r|
    r.source_files = 'Sources/InfobipCallKit/Rx/**/*.swift'
    r.dependency 'InfobipCallKit/Core'
    r.dependency 'RxSwift', '~> 6.1'          # ⊇ client 6.8–6.9
  end
end
