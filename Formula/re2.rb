class Re2 < Formula
  desc "Alternative to backtracking PCRE-style regular expression engines"
  homepage "https://github.com/google/re2"
  url "https://github.com/google/re2/archive/2019-08-01.tar.gz"
  version "20190801"
  sha256 "38bc0426ee15b5ed67957017fd18201965df0721327be13f60496f2b356e3e01"
  head "https://github.com/google/re2.git"

  bottle do
    cellar :any
    sha256 "9761a6c2400632daf81b739f56bf130619644defa30b39e457c08e6399c3e826" => :mojave
    sha256 "5f2a7eee1fcb0a895248efa37e0c861d30a53f93e9e8ee7dd254c5f854aa412e" => :high_sierra
    sha256 "d0b45927307386877b316eed8c6df9a41cdbafad12e6025bdcc64508e97eba1c" => :sierra
    sha256 "d372064613a2db069a7262841f0403716f9bd4102e587e5bff164c261d63f007" => :x86_64_linux
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    ENV.cxx11

    system "make", "install", "prefix=#{prefix}"
    MachO::Tools.change_dylib_id("#{lib}/libre2.0.0.0.dylib", "#{lib}/libre2.0.dylib") if OS.mac?
    ext = OS.mac? ? "dylib" : "so"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.0.#{ext}"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.#{ext}"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <re2/re2.h>
      #include <assert.h>
      int main() {
        assert(!RE2::FullMatch("hello", "e"));
        assert(RE2::PartialMatch("hello", "e"));
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11",
           "test.cpp", "-I#{include}", "-L#{lib}", "-pthread", "-lre2", "-o", "test"
    system "./test"
  end
end
