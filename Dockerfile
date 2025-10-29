ARG ARCH
ARG MANYLINUXIMG
FROM quay.io/pypa/${MANYLINUXIMG}_${ARCH} AS builder

# Install llvm
WORKDIR /root/install
ARG LLVM_VERSION="21.1.4"
RUN curl -L https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz > llvm-project-${LLVM_VERSION}.tar.gz \
  && tar xvf  llvm-project-${LLVM_VERSION}.tar.gz > /dev/null 2>&1 \
  && mv llvm*${LLVM_VERSION} llvm_root \
  && cd llvm_root \
  && cmake -S llvm -B build -DCMAKE_BUILD_TYPE=Release \
                            -DLLVM_ENABLE_RTTI=ON \
                            -DLLVM_INCLUDE_BENCHMARKS=OFF \
                            -DLLVM_INCLUDE_DOCS=OFF \
                            -DLLVM_INCLUDE_EXAMPLES=OFF \
                            -DLLVM_INCLUDE_TESTS=OFF \
                            -DLLVM_INCLUDE_UTILS=OFF \
                            -DLLVM_INSTALL_UTILS=OFF \
  && cmake --build build -j4 --target install

# Final stage.
FROM quay.io/pypa/${MANYLINUXIMG}_${ARCH}

# 2. Copy the entire /usr/local contents from the builder.
COPY --from=builder /usr/local/ /usr/local/

# 3. Update the linker cache.
RUN ldconfig
