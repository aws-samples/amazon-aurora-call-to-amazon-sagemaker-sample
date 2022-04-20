#Build stk base image.

1. Deploy an Ubuntu instance with at least 4 vcpu. 
2. Install packages per https://github.com/supertuxkart/stk-code/blob/master/INSTALL.md
3. `mkdir supertuxkart`
4. `cd supertuxkart`
5. `git clone https://github.com/supertuxkart/stk-code.git` 
6. `svn co https://svn.code.sf.net/p/supertuxkart/code/stk-assets stk-assets`
7. Copy Dockerfile and build.sh from [stk-base-image]
8. For the first build, use https://github.com/supertuxkart/stk-code/blob/master/INSTALL.md#compiling

```
# go into the stk-code directory
cd stk-code

# create and enter the cmake_build directory
mkdir cmake_build
cd cmake_build

# run cmake to generate the makefile
cmake ..

# compile
make -j$(nproc) SERVER_ONLY=ON
```

