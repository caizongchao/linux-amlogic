#! /bin/bash

#
# Build kernel and dtb for arm
# Usage: mkimage.sh [-k def] [-d dts | -p chip] [-c] [-h]
#

#set -x

if [ "${KBUILD_SRC}" = "" ]; then
	tree=
else
	tree=${srctree}/
fi

PRGNAME=$(basename "$0")

JLEVEL=12

ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

DEFCONFIG=meson32_defconfig
UIMAGE_LOADADDR=0x1008000
ROOTFS=""

BUILDKERNEL=false
BUILDROOTFS=false
BUILDDTB=false
DISTCLEAN=false
ALLDTS=""
ALLDEF=""

DEFDIR=${tree}arch/${ARCH}/configs
DTSDIR=${tree}arch/${ARCH}/boot/dts/amlogic



#
# list all defconfigs
#
list_defconfig()
{
	defs=$(find ${DEFDIR} -name meson*_defconfig -type f -print)

	for def in ${defs}; do
		ALLDEF="${ALLDEF} "$(basename $def)
	done
}

#
# list all dts
#
list_devicetree()
{
	echo "todo"
}


#
# find defconfig in
#
find_defconfig()
{
	cnt=$(find ${DEFDIR} -name ${1} -type f -print | wc -l)

	def=$(find ${DEFDIR} -name ${1} -type f -print)

	if [ ${cnt} -eq 1 ]; then
		DEFCOFNIG=$(basename $def)
		echo "find defconfig $DEFCONFIG"
	elif [ ${cnt} -eq 0 ]; then
		echo "find no defconfig"
		exit 1
	elif [ ${cnt} -ge 2 ]; then
		echo "find multi defconfigs"
		exit 1
	fi
}

#
# find rootfs
#
find_rootfs()
{
	if [ -f ${1} ]; then
		ROOTFS=${1}
	else
		echo "find no rootfs ${1}"
		exit 1
	fi
}

#
# find dts
#
find_devicetree()
{
	cnt=$(find ${DTSDIR} -type f -name *${1}*.dts -print | wc -l)

	if [ ${cnt} -eq 0 ]; then
		echo "find no dts"
		exit 1
	fi

	dts=$(find ${DTSDIR} -type f -name *${1}*.dts)

	for d in ${dts}; do
		ALLDTS="${ALLDTS} $(basename $d)"
	done
}


#
# make distclean
#
make_distclean()
{
	make ARCH=${ARCH} distclean > /dev/null 2>&1
}


#
# make defconfig
#
make_defconfig()
{
	make ARCH=${ARCH} ${DEFCONFIG}
}


#
#build kernel
#
build_kernel()
{
	OPTION=""
	OPTION=${OPTION}" ARCH=${ARCH}"
	OPTION=${OPTION}" UIMAGE_LOADADDR=${UIMAGE_LOADADDR}"
	if [ "${BUILDROOTFS}" = "true" ]; then
		OPTION=${OPTION}" CONFIG_INITRAMFS_SOURCE=${ROOTFS}"
	fi

	make ${OPTION} uImage -j${JLEVEL}
}


#
# build dtb
#
build_dtb()
{
	for d in ${ALLDTS}; do
		echo "compile dtb ${d%.dts} ..."
		make ARCH=${ARCH} ${d%.dts}.dtb
		if [ $? -ne 0 ]; then exit 1; fi
	done
}


#
# examples
#
usage_example()
{
	echo -e "\nExamples:"
	echo -e "  # build kernel using default ${DEFCONFIG}"
	echo -e "\033[32;1m  $PRGNAME\033[0m\n"

	echo -e "  # build kernel using defconfig <meson64_defconfig>\c"
	echo -e " specified by the option -k"
	echo -e "\033[32;1m  $PRGNAME -k meson64_defconfig\033[0m\n"

	echo -e "  # build all dtb for the board with prefix or suffix\c"
	echo -e " <p320> specified by the option -d"
	echo -e "\033[32;1m  $PRGNAME -d p320\033[0m\n"

	echo -e "  # build all dtb for the chip with prefix <txl> specified\c"
	echo -e " by the option -p"
	echo -e "\033[32;1m  $PRGNAME -p txl\033[0m\n"

	echo -e "  # make distclean and build kernel and dtb"
	echo -e "\033[32;1m  $PRGNAME -k meson64_defconfig -d p320 -c\033[0m\n"
}


#
# usage
#
usage()
{
	echo -e "Usage: $PRGNAME [-k def] [-d dts | -p chip] [-c] [-h]\n"
	echo -e "  -k	specify defconfig with full name"
	echo -e "  -f	specify rootfs"
	echo -e "  -d	specify dts or the prefix or suffix"
	echo -e "  -p	specify the prefix of dts for the chip"
	echo -e "  -c	make distclean"
	echo -e "  -h	print help summary and examples"
}


while getopts :k:f:d:p:ch opt; do
	case $opt in
		k)
			BUILDKERNEL=true
			find_defconfig ${OPTARG}
			;;
		f)
			BUILDKERNEL=true
			BUILDROOTFS=true
			find_rootfs ${OPTARG}
			;;
		d)
			BUILDDTB=true
			find_devicetree _${OPTARG}
			;;
		p)
			BUILDDTB=true
			find_devicetree ${OPTARG}_
			;;
		c)
			DISTCLEAN=true
			;;
		h)
			usage
			usage_example
			exit 1
			;;

		\?)
			echo "invalid option $OPTARG"
			usage
			exit 1
			;;
		:)
			case $OPTARG in
				k)
					echo "missing argument to -k"
					usage
					exit 1
					;;
				d)
					echo "missing argument to -d"
					usage
					exit 1
					;;
				p)
					echo "missing argument to -p"
					usage
					exit 1
					;;
			esac
			;;
	esac
done

if [ $# -eq 0 ];then
	BUILDKERNEL=true
fi

if [ "${DISTCLEAN}" = "true" ]; then
	make_distclean
fi

if [ "${BUILDKERNEL}" = "true" ] || [ "${BUILDDTB}" = "true" ];then
	make_defconfig
fi

if [ "${BUILDKERNEL}" = "true" ]; then
	echo "start compile kernel ..."
	build_kernel
fi

if [ "${BUILDDTB}" = "true" ]; then
	echo "start compile dtb ..."
	build_dtb
fi


exit 1
