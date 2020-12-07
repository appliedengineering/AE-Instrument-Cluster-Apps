# Install script for directory: D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "D:/Program Files (x86)/JZMQ")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/Debug/jzmq.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/Release/jzmq.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/MinSizeRel/jzmq.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/RelWithDebInfo/jzmq.lib")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/Debug/jzmq.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/Release/jzmq.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/MinSizeRel/jzmq.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/RelWithDebInfo/jzmq.dll")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/lib/zmq.jar")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/doc" TYPE FILE FILES
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/AUTHORS"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/COPYING"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/COPYING.LESSER"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/ChangeLog"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/INSTALL"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/NEWS"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/README"
    "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/README-PERF"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE PROGRAM FILES
    "C:/Program Files (x86)/Visual Studio 2019/VC/Redist/MSVC/14.27.29016/x64/Microsoft.VC142.CRT/msvcp140.dll"
    "C:/Program Files (x86)/Visual Studio 2019/VC/Redist/MSVC/14.27.29016/x64/Microsoft.VC142.CRT/vcruntime140.dll"
    "C:/Program Files (x86)/Visual Studio 2019/VC/Redist/MSVC/14.27.29016/x64/Microsoft.VC142.CRT/concrt140.dll"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE DIRECTORY FILES "")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "D:/Users/richa/Desktop/Misc/Github Repositories/AE-Intrument-Cluster-Apps/Android-inst-clstr/JZMQ/jzmq/jzmq-jni/build64/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
