Pod::Spec.new do |s|
    s.name                    = 'scandit-datacapture-frameworks-id'
    s.version                 = '7.5.0-beta.1'
    s.summary                 = 'Scandit Frameworks Shared Id module'
    s.homepage                = 'https://github.com/Scandit/scandit-datacapture-frameworks-id'
    s.license                 = { :type => 'Apache-2.0' , :text => 'Licensed under the Apache License, Version 2.0 (the "License");' }
    s.author                  = { 'Scandit' => 'support@scandit.com' }
    s.platforms               = { :ios => '14.0' }
    s.source                  = { :git => 'https://github.com/Scandit/scandit-datacapture-frameworks-id.git', :tag => '7.5.0-beta.1' }
    s.swift_version           = '5.7'
    s.source_files            = 'Sources/**/*.{h,m,swift}'
    s.requires_arc            = true
    s.module_name             = 'ScanditFrameworksId'
    s.header_dir              = 'ScanditFrameworksId'

    s.dependency 'ScanditIdCapture', '= 7.5.0-beta.1'
    s.dependency 'scandit-datacapture-frameworks-core', '= 7.5.0-beta.1'
end
