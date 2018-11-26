fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios patch
```
fastlane ios patch
```
This does the following: 



- Runs the unit tests

- Ensures Cocoapods compatibility

- Bumps the patch version
### ios minor
```
fastlane ios minor
```
This does the following: 



- Runs the unit tests

- Ensures Cocoapods compatibility

- Bumps the minor version
### ios major
```
fastlane ios major
```
This does the following: 



- Runs the unit tests

- Ensures Cocoapods compatibility

- Bumps the major version
### ios test
```
fastlane ios test
```

### ios submit_pod
```
fastlane ios submit_pod
```
Push the repo to remote and submits the Pod to the given spec repository. Do this after running update to run tests, bump versions, and commit changes.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
