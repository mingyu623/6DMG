# Mingyu @ Oct 14 2016

This is the *extra* instructions to install HTK 3.4.1
on Ubuntu 14.04 (64bit)

1. Get extra packages for 32b compilation support
  > sudo apt-get install g++-multilib
  > sudo apt-get install libX11-dev libX11-dev:i386

2. Modify configure.ac to add a new include path for some required system headers.
-- configure.ac --
case "$host" in
    *x86_64*linux*)
       CFLAGS="-m32 -ansi -D_SVID_SOURCE -DOSS_AUDIO -D'ARCH=\"$host_cpu\"' $CFLAGS"
       CFLAGS="-I/usr/include/x86_64-linux-gnu/ $CFLAGS"
       LDFLAGS="-L/usr/X11R6/lib $LDFLAGS"
       ARCH=linux
       trad_bin_dir=linux

3. Configure with autoconf again, then make and install HTK
  > autoconf
  > ./configure
  > make all
  > sudo make install

4. Through the training/testing process, Perl Parallel::ForkManager module is used
   for parallel processing. Make sure to install Parallel::ForkManager first
  > cpan Parallel::ForkManager

