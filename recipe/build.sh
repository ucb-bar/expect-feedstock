aclocal
autoconf
( cd testsuite
  autoconf -I.. )

# Expect 5.45.4 ships an old config.sub that does not recognize conda
# triplets such as aarch64-conda-linux-gnu / x86_64-conda-linux-gnu.
find . -name config.sub -o -name config.guess | while read -r f; do
  cp "${BUILD_PREFIX}/share/gnuconfig/$(basename "${f}")" "${f}"
done

# GCC 14+ errors on implicit int / implicit function declarations. Expect's
# configure tests are K&R C, so those failures leave PTY_TYPE empty and
# configure looks for pty_.c. Keep the tests compiling.
export CFLAGS="${CFLAGS} -fpermissive -Wno-implicit-int -Wno-implicit-function-declaration"

./configure --prefix=$PREFIX --build=$BUILD --host=$HOST --with-tclinclude=$PREFIX/include
make -j ${CPU_COUNT}
make test
make -j ${CPU_COUNT} install

mv $PREFIX/lib/tcl*/expect${PKG_VERSION}/libexpect${PKG_VERSION}.so $PREFIX/lib
ln -s libexpect${PKG_VERSION}.so $PREFIX/lib/libexpect.so
