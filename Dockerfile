ARG ARCH=x86_64
ARG MANYLINUXIMG
FROM quay.io/pypa/${MANYLINUXIMG}_${ARCH}

# We place ourself in some safe location to do all installations
RUN cd \
  && mkdir install

# Install llvm
WORKDIR /root/install
ARG LLVM_VERSION="20.1.2"
RUN curl -L https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz > llvm-project-${LLVM_VERSION}.tar.gz \
  && tar xvf  llvm-project-${LLVM_VERSION}.tar.gz > /dev/null 2>&1 \
  && mv llvm*${LLVM_VERSION} llvm_root \
  && cd llvm_root \
  && cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release \
                            -DLLVM_ENABLE_RTTI=ON \
                            -DLLVM_ENABLE_TERMINFO=OFF \
                            -DLLVM_INCLUDE_BENCHMARKS=OFF \
                            -DLLVM_INCLUDE_DOCS=OFF \
                            -DLLVM_INCLUDE_EXAMPLES=OFF \
                            -DLLVM_INCLUDE_GO_TESTS=OFF \
                            -DLLVM_INCLUDE_TESTS=OFF \
                            -DLLVM_INCLUDE_UTILS=OFF \
                            -DLLVM_INSTALL_UTILS=OFF \
  && cmake --build build -j4 --target install
  
# Making sure the new libraries (in /usr/local/lib) can be found
RUN ldconfig
