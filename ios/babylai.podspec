#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint babylai.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'babylai'
  s.version          = '1.0.14'
  s.summary          = 'Flutter plugin for BabylAI SDK - AI-powered chat integration.'
  s.description      = <<-DESC
A Flutter plugin that provides integration with BabylAI chat functionality, 
supporting multiple themes, languages, and seamless native SDK integration.
                       DESC
  s.homepage         = 'https://github.com/AAU-IQ/BabylAI-Flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BabylAI' => 'info@babylai.net' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # BabylAI iOS SDK - fetch prebuilt XCFramework from remote repo during pod install
  # This avoids manual Xcode setup and SPM configuration in consuming apps
  remote_dir = 'BabylAI-Remote'
  framework_path = File.join(remote_dir, 'BabylAI.xcframework')

  s.prepare_command = <<-CMD
    set -euo pipefail
    REPO_URL=${BABYLAI_IOS_SDK_URL:-https://github.com/AAU-IQ/BabylAI-iOS.git}
    BRANCH_OR_TAG=${BABYLAI_IOS_SDK_REF:-}

    # If no explicit ref provided, prefer YAML config (sdk_config.yaml), then legacy files
    if [ -z "$BRANCH_OR_TAG" ]; then
      if [ -f "../sdk_config.yaml" ]; then
        RAW_REF=$(ruby -ryaml -e 'cfg=YAML.load_file("../sdk_config.yaml"); v=(cfg["ios"]||{})["ref"] || (cfg["ios"]||{})["version"]; print v.to_s')
      fi
      if [ -z "$RAW_REF" ] && [ -f "../ios_sdk_version.txt" ]; then
        RAW_REF=$(cat ../ios_sdk_version.txt | tr -d '\n' | tr -d ' ')
      elif [ -z "$RAW_REF" ] && [ -f "../sdk_version.txt" ]; then
        RAW_REF=$(cat ../sdk_version.txt | tr -d '\n' | tr -d ' ')
      fi
      if [ -n "$RAW_REF" ]; then
        # If the ref looks like 1.2.3, prefix with 'v' (matches repo tags)
        if echo "$RAW_REF" | grep -Eq '^[0-9]'; then
          BRANCH_OR_TAG="v${RAW_REF}"
        else
          BRANCH_OR_TAG="$RAW_REF"
        fi
      fi
      if [ -z "$BRANCH_OR_TAG" ]; then BRANCH_OR_TAG="main"; fi
    fi
    DEST_DIR="#{remote_dir}"
    FRAMEWORK_DEST="#{framework_path}"

    echo "[BabylAI] Fetching iOS SDK from $REPO_URL@$BRANCH_OR_TAG"
    rm -rf "$DEST_DIR"
    git clone --depth 1 --branch "$BRANCH_OR_TAG" "$REPO_URL" "$DEST_DIR.tmp"
    # Copy prebuilt XCFramework from repo
    mkdir -p "$DEST_DIR"
    if [ -d "$DEST_DIR.tmp/Sources/BabylAI-iOS/BabylAI.xcframework" ]; then
      cp -R "$DEST_DIR.tmp/Sources/BabylAI-iOS/BabylAI.xcframework" "$FRAMEWORK_DEST"
    elif [ -d "$DEST_DIR.tmp/BabylAI.xcframework" ]; then
      cp -R "$DEST_DIR.tmp/BabylAI.xcframework" "$FRAMEWORK_DEST"
    else
      echo "❌ BabylAI.xcframework not found in repository. Ensure releases contain the XCFramework." >&2
      exit 1
    fi
    rm -rf "$DEST_DIR.tmp"
    echo "[BabylAI] XCFramework ready at $FRAMEWORK_DEST"
  CMD

  s.vendored_frameworks = framework_path
  s.preserve_paths = remote_dir
  
  # Required dependencies for BabylAI SDK
  s.dependency 'Ably', '~> 1.2'
  s.dependency 'lottie-ios', '~> 4.5'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_VERSION' => '5.0'
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'babylai_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
