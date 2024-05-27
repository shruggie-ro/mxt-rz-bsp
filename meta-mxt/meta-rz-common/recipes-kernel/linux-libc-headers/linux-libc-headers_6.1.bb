require recipes-kernel/linux-libc-headers/linux-libc-headers.inc

KBRANCH = "${@oe.utils.conditional("IS_RT_BSP", "1", "linux-6.1.y-cip", "linux-6.1.y-cip",d)}"
SRCREV_machine = "${@oe.utils.conditional("IS_RT_BSP", "1", "a5d281b04d5bd8e58f9d1de802632ae9c5a262c8", "4e312831fe188da5bb477eeae886bcf07184f0eb",d)}"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

FILESEXTRAPATHS:prepend := "${THISDIR}/../linux/linux-cip:"

S = "${WORKDIR}/git"

SRC_URI = " \
	git://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git;branch=${KBRANCH};name=machine \
"

# below overrides the multilib list - can be dropped for the next LTS
do_install_armmultilib () {
	oe_multilib_header asm/auxvec.h asm/bitsperlong.h asm/byteorder.h asm/fcntl.h asm/hwcap.h asm/ioctls.h asm/kvm_para.h asm/mman.h asm/param.h asm/perf_regs.h asm/bpf_perf_event.h
	oe_multilib_header asm/posix_types.h asm/ptrace.h  asm/setup.h  asm/sigcontext.h asm/siginfo.h asm/signal.h asm/stat.h  asm/statfs.h asm/swab.h  asm/types.h asm/unistd.h
}
