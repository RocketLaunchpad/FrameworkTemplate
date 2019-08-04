# Framework Template

This repository contains a script to generate a new iOS CocoaTouch Framework. The output framework contains source code, unit test code, and an example project.

## To create a new framework

Clone this repo and open a Terminal in the resulting directory. Run the following command:

```
$ bin/start_new_project.rb OUTPUT_PATH
```

The script will prompt you for concrete values to substitute into the sample project when copying.

## To edit the framework template

The template is located in `src/__PRODUCT_NAME__`. This is an ordinary Xcode project that you should be able to build and run.

Note that the project uses certain symbols that are expanded by the Ruby script when copying the project. These are:

* `__PRODUCT_NAME__` is the name of the framework product
* `__ORGANIZATION_NAME__` is the name of the organization (e.g., `Rocket Insights, Inc.`)
* `__ORGANIZATION_ID__` is the bundle identifier prefix (e.g., `com.rocketinsights`)
* `__DATE__` is the date that the script is run, in YYYY-MM-DD format
* `__YEAR__` is the four-digit year

After modifying the template, you should generate a new framework using the Ruby script to verify if compiles and runs.

