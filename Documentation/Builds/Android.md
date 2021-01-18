Hello!
---

Here are instructions for compiling [JZMQ](https://github.com/zeromq/jzmq) on Mac OS / Linux. 
Instructions will be adapted from here: http://wiki.zeromq.org/build:android

Before Starting
---

Before getting started, make sure you download + install the [Java Runtime](https://www.oracle.com/java/technologies/javase-jre8-downloads.html) and [Development kit](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html). You may need to sign up for an Oracle account.

[MacOs Catalina and up only] Due to changes in MacOS Catalina and the outdated build script, you must follow instructions [here](https://stackoverflow.com/a/59421615/) in order to prevent confusion later on. If you decide to recompile after rebooting your mac, you must use the `sudo mount -uw /` command again.

Since JZMQ is a wrapper for the C++ libzmq library, it is required to use the Android NDK to use C++ functions natively. You can find the NDK here: https://developer.android.com/ndk/downloads. For Mac, make sure you download the ZIP and not the DMG. 

Once you download the NDK ZIP, create a folder named "tmp" and extract the ndk to the tmp folder. So, in my case, the NDK is called "android-ndk-r21d" so, inside /tmp/android-ndk-r22, I have the ndk.

Open the terminal and navigate to /tmp/

Run `sudo ./android-ndk-r22/build/tools/make-standalone-toolchain.sh --install-dir=/opt/android-toolchain` then `export PATH=/opt/android-toolchain/bin:$PATH` to set up the NDK. You may replace r22 with whatever version you have.

NOTE: Everytime you compile, you MUST run the above command to configure to NDK otherwise you'll get a `bad ELF magic` error.

libzmq
---
Use the following commands

NOTE: in the `./configure` command, you can add options for libzmq. For example, if I wanted to compile with draft methods such as Radio / Dish, you would add `--enable-drafts` right after `./configure`. You can also change which architecture to compile for by changing the `--host=` flag. For exmaple, below, it is compiling for arm but we can also compile for x86 by using `--host=i686-linux-android`. You can find the complete architecture list here: https://developer.android.com/ndk/guides/other_build_systems.

```
cd /tmp/
git clone https://github.com/zeromq/libzmq.git
cd libzmq/
./autogen.sh
./configure --enable-static --enable-drafts --disable-shared --prefix=$OUTPUT_DIR LDFLAGS="-L$OUTPUT_DIR/lib" CPPFLAGS="-fPIC -I$OUTPUT_DIR/include" --host=arm-linux-androideabi
make
sudo make install
```

NOTE:
Basic installation on OS X may fail in `Making all` in doc step. This
error can be resolved by adding environment variable for shell.

export XML_CATALOG_FILES=/usr/local/etc/xml/catalog 

Write comamnd above in shell for instant resolve, or append command into
shell profile file and reload for permanent resolve.

jzmq
---
Use the following commands

NOTE: for changing the architecture, the same thing applies here as with libzmq.

```
cd /tmp/
git clone https://github.com/richardwei6/jzmq.git
cd jzmq/jzmq-jni/
./autogen.sh
./configure --prefix=$OUTPUT_DIR --with-zeromq=$OUTPUT_DIR CPPFLAGS="-fPIC -I$OUTPUT_DIR/include" LDFLAGS="-L$OUTPUT_DIR/lib" --disable-version --host=arm-linux-androideabi
make
sudo make install
```
if you're having issues with Java, make sure to set your `JAVA_HOME` path.

if you're having issues with Java not finding include files, first, use this command: 
`echo $(/usr/libexec/java_home)`
to find the location of your JDK. Then, go to that location + `/include/` so, in my case, the path I needed to go to was `/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home/include/`.

Now, in this folder, you should also be able to see a folder named "darwin" (or whatever the name of your os is) that includes two headers. **Copy** (DO NOT MOVE) those headers into `/include/`. 

Then, use this command:`export PATH=$(/usr/libexec/java_home)/bin:$PATH`.

Finding the generated libs
---

You should now be able to go to Finder and find the compiled files.

Here's a good diagram of what it should look like:
```
├── include
│   ├── zmq.h
│   └── zmq_utils.h
├── lib
│   ├── libjzmq.a
│   ├── libjzmq.la
│   ├── libjzmq.so
│   ├── libzmq.a
│   ├── libzmq.la
│   └── pkgconfig
│       └── libzmq.pc
└── share
    ├── java
    │   └── zmq.jar
    └── man
        ├── man3
        └── man7
```
       
NOTE: Since we didn't assign a prefix, the folders will be on the root folder of your drive. So, the include folder will be `/include/`, lib folder will be `/lib/` and so on.


NDK Library
---

If you're going to move the built libraries to a separate system without the NDK, you will need to navigate to `/android-ndk-r(ver # here)/sources/cxx-stl/llvm-libc++/libs/(architecture)/` and copy all the files there into the same jniLibs folder as libjzmq.so.
