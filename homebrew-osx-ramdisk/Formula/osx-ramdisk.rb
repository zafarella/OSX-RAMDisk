class ramdisk < Formula
  desc "Creates ram-disk making browsers and IDEs fly."
  homepage "http://zafarella.github.io/OSX-RAMDisk/"
  url "https://github.com/zafarella/OSX-RAMDisk/tarball/master"
  sha256 ""
  head "https://github.com/zafarella/OSX-RAMDisk.git"
  version "1.0"

  depends_on "newfs_hfs"

  def install
    system "Contents/MacOS/startupRAMDiskandCacheMover.sh"
  end

  test do
    system "ls -lsa /Volumes/${USER}"
  end

end
