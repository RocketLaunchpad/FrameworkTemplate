# Framework Template

This repository contains a script to generate a new iOS CocoaTouch Framework. The output framework contains source code, unit test code, a CocoaPods Podspec, and an example project.

## To create a new framework

Clone this repo and open a Terminal in the resulting directory. Run the following command:

```
$ bin/start_new_project.rb OUTPUT_PATH
```

The script will prompt you for concrete values to substitute into the sample project when copying. Once finished, run the following:

```
$ cd OUTPUT_PATH
$ pod install
$ open .
```

Open the xcworkspace file, then build and run the example project.

## To edit the framework template

The template is located in `src/__PRODUCT_NAME__`. This is an ordinary Xcode project that you should be able to build and run.

Note that the project uses certain symbols that are expanded by the Ruby script when copying the project. These are:

* `__PRODUCT_NAME__` is the name of the framework product
* `__ORGANIZATION_NAME__` is the name of the organization (e.g., `Rocket Insights, Inc.`)
* `__ORGANIZATION_ID__` is the bundle identifier prefix (e.g., `com.rocketinsights`)
* `__DATE__` is the date that the script is run, in YYYY-MM-DD format
* `__YEAR__` is the four-digit year

After modifying the template, you should generate a new framework using the Ruby script to verify if compiles and runs.

## CocoaPods Notes

CocoaPods are used for dependency management. Before opening the workspace, you need to run `pod install`. This adds the framework as a dependency for the example app. This is necessary for the framework's dependencies to be correctly added to the resulting app.

**IMPORTANT** If your framework has 3rd party dependencies, you need to include them in both the Podfile and the Podspec:

- The dependencies are defined in the Podspec so that they are correctly pulled in when integrating the framework via CocoaPods.
- The dependencies are defined in the Podfile so that they are pulled into the framework's workspace, enabling development of the framework.

**IMPORTANT** When adding or removing files in the framework target, you will need to run `pod install` again for them to be picked up by the example app.

You will need to set the Git URL in the resulting Podspec.

