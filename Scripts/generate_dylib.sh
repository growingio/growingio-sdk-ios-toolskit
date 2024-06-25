#!/bin/bash

LOGGER_MODE=1 # 0=silent/1=info/2=verbose
logger() {
	mode=$1
	message=$2
	if [[ $mode == '-e' ]]; then
		echo "\033[31m[GrowingAnalytics] [ERROR] ${message}\033[0m"
	elif [[ $mode == '-i' && LOGGER_MODE -gt 0 ]]; then
		echo "\033[36m[GrowingAnalytics] [INFO] ${message}\033[0m"
	elif [[ $mode == '-v' && LOGGER_MODE -gt 1 ]]; then
		echo "\033[32m[GrowingAnalytics] [VERBOSE] ${message}\033[0m"
	fi
}

MAIN_FRAMEWORK_NAME='GrowingToolsKit'
copyAndModifyPodspec() {
	logger -v "step: backup podspec"
	cp "${MAIN_FRAMEWORK_NAME}.podspec" "${MAIN_FRAMEWORK_NAME}-backup.podspec"
	modifyPodspec "${MAIN_FRAMEWORK_NAME}.podspec"
}
modifyPodspec() {
	podspec=$1
	logger -v "step: change default subspec"
	sed -i '' "s/s.default_subspec  = 'Default'/s.default_subspec = 'UseInRelease'/g" ${podspec}
}

FOLDER_NAME='generate'
PROJECT_FOR_IOS_PATH=${FOLDER_NAME}/Project/ios
generateProject() {
	logger -v "step: gem bundle install"
	sudo -E bundle install || exit 1
	rm -rf $FOLDER_NAME
	mkdir $FOLDER_NAME
	logger -v "step: generate xcodeproj from podspec using square/cocoapods-generate"
	args="--local-sources=./ --platforms=ios --gen-directory=${PROJECT_FOR_IOS_PATH} --clean"
	if [[ $LOGGER_MODE -eq 0 ]]; then
		args+=" --silent"
	elif [[ $LOGGER_MODE -eq 2 ]]; then
		args+=" --verbose"
	fi

	bundle exec pod gen ${MAIN_FRAMEWORK_NAME}.podspec $args || exit 1

	logger -v "step: modify build settings using CocoaPods/Xcodeproj"
	targets=$(bundle exec ruby ./Scripts/modifyPodsXcodeproj.ruby "./${PROJECT_FOR_IOS_PATH}/${MAIN_FRAMEWORK_NAME}/Pods/Pods.xcodeproj")

	logger -v "step: reset podspec"
	mv "${MAIN_FRAMEWORK_NAME}.podspec" "./${FOLDER_NAME}/${MAIN_FRAMEWORK_NAME}.podspec"
	mv "${MAIN_FRAMEWORK_NAME}-backup.podspec" "${MAIN_FRAMEWORK_NAME}.podspec"
	# open ./${PROJECT_FOR_IOS_PATH}/${MAIN_FRAMEWORK_NAME}/${MAIN_FRAMEWORK_NAME}.xcworkspace
}

generateFramework() {
	archive_path="./${FOLDER_NAME}/archive"
	framework_name=$MAIN_FRAMEWORK_NAME
	framework_path_suffix=.xcarchive/Products/Library/Frameworks/${framework_name//-/_}.framework
	iphone_os_archive_path="${archive_path}/iphoneos"
	release_path="./${FOLDER_NAME}/Release"
	output_path="${release_path}/${framework_name//-/_}.framework"
	common_args="archive -workspace ./${PROJECT_FOR_IOS_PATH}/${MAIN_FRAMEWORK_NAME}/${MAIN_FRAMEWORK_NAME}.xcworkspace \
	-scheme ${framework_name} -configuration 'Release' -derivedDataPath ./${FOLDER_NAME}/derivedData"
	if [[ $LOGGER_MODE -eq 0 ]]; then
		common_args+=' -quiet'
	elif [[ $LOGGER_MODE -eq 2 ]]; then
		common_args+=' -verbose'
	fi

	rm -rf ${output_path}

	logger -v "step: generate ${framework_name} ios-arm64 framework"
	xcodebuild ${common_args} \
		-destination "generic/platform=iOS" \
		-archivePath ${iphone_os_archive_path} || exit 1

	mkdir ${release_path}
	cp -r ${iphone_os_archive_path}${framework_path_suffix} ${output_path}
	cd ${output_path}
	cp $MAIN_FRAMEWORK_NAME ./${MAIN_FRAMEWORK_NAME}.dylib
	install_name_tool -id @rpath/${MAIN_FRAMEWORK_NAME}.dylib ./${MAIN_FRAMEWORK_NAME}.dylib
}

signDylib() {
	codesign -s - --timestamp=none --force ./${MAIN_FRAMEWORK_NAME}.dylib
	codesign -dvvv ./${MAIN_FRAMEWORK_NAME}.dylib
}

beginGenerate() {
	logger -i "job: backup and modify podspec"
	copyAndModifyPodspec
	logger -i "job: generate xcodeproj from podspec"
	generateProject
	logger -i "job: generate framework"
	generateFramework
	logger -i "job: sign dylib"
	signDylib

	echo "\033[36m[GrowingAnalytics] WINNER WINNER, CHICKEN DINNER!\033[0m"
	open ../
}

main() {
	beginGenerate
}


if [ $# -eq 0 ]; then
	main
else
	execFunc="main"
	for arg in "$@"; do
		if [[ $arg == '-h' || $arg == '--help' ]]; then
			echo "\033[32m
		usage: 
		1. cd growingio-sdk-ios-toolskit folder
		2. run script: sh ./Scripts/generate_dylib.sh -v | grep '\[GrowingAnalytics\]'
		3. drag all files in ./generate/Release/ into your jailbreak device with path var/jb/Libary/MobileSubstrate/DynamicLibraries/

		example:
		sh ./Scripts/generate_dylib.sh -v
		sh ./Scripts/generate_dylib.sh --verbose
		sh ./Scripts/generate_dylib.sh --silent
		sh ./Scripts/generate_dylib.sh --help
		
			\033[0m"
			exit 0
		elif [[ $arg == '-s' || $arg == '--silent' ]]; then
	        LOGGER_MODE=0
	    elif [[ $arg == '-v' || $arg == '--verbose' ]]; then
			LOGGER_MODE=2
		else
			execFunc="$arg"
		fi
	done
	"$execFunc"
fi


