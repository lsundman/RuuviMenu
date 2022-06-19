cmake_minimum_required(VERSION 3.15)

project(RuuviMenu LANGUAGES Swift)

set(CMAKE_Swift_LANGUAGE_VERSION 5.2)

add_executable(
  ${CMAKE_PROJECT_NAME} MACOSX_BUNDLE
  assets/Ruuvi.icns
  src/main.swift
  src/AppDelegate.swift
  src/BluetoothDelegate.swift
  src/StatusBarController.swift
  src/RuuviParsing.swift
  src/PrefsViewController.swift)

set_target_properties(
  RuuviMenu
  PROPERTIES MACOSX_BUNDLE True
             MACOSX_BUNDLE_GUI_IDENTIFIER
             com.github.lsundman.${CMAKE_PROJECT_NAME}
             MACOSX_BUNDLE_BUNDLE_NAME ${CMAKE_PROJECT_NAME}
             MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
             MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
             MACOSX_BUNDLE_INFO_PLIST ${PROJECT_SOURCE_DIR}/assets/Info.plist
             MACOSX_BUNDLE_ICON_FILE Ruuvi.icns
             XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "YES"
             XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "-"
             XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
             ${PROJECT_SOURCE_DIR}/assets/app.entitlements)

set_source_files_properties(assets/Ruuvi.icns PROPERTIES MACOSX_PACKAGE_LOCATION
                                                         "Resources")
