# netbsd_utils
a set of small utilities for NetBSD operating system

fetching pkgsrc

  # netbsd_pkgsrc_fetch.csh

updating pkgsrc

  # netbsd_pkgsrc_update.csh /usr/pkgsrc

cleaning pkgsrc work directories

  # netbsd_pkgsrc_clean.csh

fetching src and xsrc

  # netbsd_src_fetch.csh

updating src and xsrc

  # netbsd_src_update.csh /usr/src /usr/xsrc

building kernel

  # cd /usr/src/sys/arch/amd64/conf
  # cp GENERIC MY_GEN_YYYYMMDD
  # vi MY_GEN_YYYYMMDD
  # netbsd_build_kernel_make.csh /usr/src/sys/arch/amd64/conf/MY_GEN_YYYYMMDD

installing kernel

  # netbsd_build_kernel_install.csh /usr/src/sys/arch/amd64/conf/MY_GEN_YYYYMMDD

building kernel modules

  # netbsd_build_modules_make.csh

installing kernel modules

  # netbsd_build_modules_install.csh

building user-land

  # netbsd_build_dist_make.csh

installing user-land

  # netbsd_build_dist_install.csh
