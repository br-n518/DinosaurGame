#!/bin/bash

RELEASE_ALIAS="dinosaurgame"
RELEASE_CN="username"

keytool -keyalg RSA -genkeypair -storetype pkcs12 -alias "androiddebugkey" -keypass "android" -keystore debug.keystore -storepass "android" -dname "CN=Android Debug,O=Android,C=US" -validity 9999

keytool -keyalg RSA -genkeypair -storetype pkcs12 -alias "$RELEASE_ALIAS" -keystore release.keystore -dname "CN=$RELEASE_CN,O=example.com,C=US" -validity 9999
