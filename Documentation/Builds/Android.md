Hello!
---

Here are instructions for compiling [JZMQ](https://github.com/zeromq/jzmq) on Mac OS / Linux. 
Instructions will be adapted from here: http://wiki.zeromq.org/build:android

Before Starting
---

Before getting started, make sure you download + install the [Java Runtime](https://www.oracle.com/java/technologies/javase-jre8-downloads.html) and [Development kit](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html). You may need to sign up for an Oracle account.

[MacOs Catalina and up only] Due to changes in MacOS Catalina and the outdated build script, you must follow instructions [here](https://stackoverflow.com/a/59421615/) in order to prevent confusion later on. If you decide to recompile after rebooting your mac, you must use the `sudo mount -uw /` command again.

libzmq
---
