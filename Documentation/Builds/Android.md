Hello!
---

Here are instructions for compiling [JZMQ](https://github.com/zeromq/jzmq) on Mac OS / Linux. 
Instructions will be adapted from here: http://wiki.zeromq.org/build:android

Before Starting
---

Before getting started, make sure you download + install the [Java Runtime](https://www.oracle.com/java/technologies/javase-jre8-downloads.html) and [Development kit](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html). You may need to sign up for an Oracle account.

[MacOs Catalina and up only] Due to changes in MacOS Catalina and the outdated build script, you must follow instructions [here](https://stackoverflow.com/a/59421615/) in order to prevent confusion later on. If you decide to recompile after rebooting your mac, you must use the `sudo mount -uw /` command again.

Since JZMQ is a wrapper for the C++ libzmq library, it is required to use the Android NDK to use C++ functions natively. You can find the NDK here: https://developer.android.com/ndk/downloads. For Mac, make sure you download the ZIP and not the DMG. 

Once you download the NDK ZIP, create a folder named "tmp" and extract the ndk to the tmp folder. So, in my case, the NDK is called "android-ndk-r21d" so, inside /tmp/android-ndk-r21d, I have the ndk.

Open the terminal and navigate to /tmp/

Run `sudo ./android-ndk-r21d/build/tools/make-standalone-toolchain.sh --install-dir=/opt/android-toolchain` then `export PATH=/opt/android-toolchain/bin:$PATH` to set up the NDK. You may replace r21d with whatever version you have.

libzmq
---
Use the following commands

NOTE: in the `./configure` command, you can add options for libzmq. For example, if I wanted to compile with draft methods such as Radio / Dish, you would add `--enable-drafts` right after `./configure`. You can also change which architecture to compile for by changing the `--host=` flag.

```
cd /tmp/
git clone https://github.com/zeromq/libzmq.git
cd libzmq/
./autogen.sh
./configure --enable-static --disable-shared --host=arm-linux-androideabi --prefix=$OUTPUT_DIR LDFLAGS="-L$OUTPUT_DIR/lib" CPPFLAGS="-fPIC -I$OUTPUT_DIR/include"
make
make install
```

jzmq
---
