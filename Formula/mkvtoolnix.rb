class Mkvtoolnix < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://www.bunkus.org/videotools/mkvtoolnix/"
  url "https://mkvtoolnix.download/sources/mkvtoolnix-19.0.0.tar.xz"
  sha256 "4b4af84cfdf3062f8ca4ab3c37854be7cd9a71bcf5c46b8ca805a101d414b6a1"

  bottle do
    sha256 "1b5451b54383d16d66601f233f66b3ad8670a08d5e18b10860545e91fec7a857" => :high_sierra
    sha256 "88d12136fe632d646683bffdb07555c77c718b4350829a0eccacf4c208890d1e" => :sierra
    sha256 "fcb92e24338a71ce18ce41e5166a4559a91d4b49cbd054c06a225308c19a2ec6" => :el_capitan
  end

  head do
    url "https://github.com/mbunkus/mkvtoolnix.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option "with-qt", "Build with Qt GUI"

  deprecated_option "with-qt5" => "with-qt"

  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "pugixml" => :build
  depends_on :ruby => ["1.9", :build]
  depends_on "boost"
  depends_on "libebml"
  depends_on "libmatroska"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "flac" => :recommended
  depends_on "libmagic" => :recommended
  depends_on "qt" => :optional
  depends_on "gettext" => :optional

  needs :cxx11

  def install
    ENV.cxx11

    features = %w[libogg libvorbis libebml libmatroska]
    features << "flac" if build.with? "flac"
    features << "libmagic" if build.with? "libmagic"

    extra_includes = ""
    extra_libs = ""
    features.each do |feature|
      extra_includes << "#{Formula[feature].opt_include};"
      extra_libs << "#{Formula[feature].opt_lib};"
    end
    extra_includes.chop!
    extra_libs.chop!

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-docbook-xsl-root=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
      --with-extra-includes=#{extra_includes}
      --with-extra-libs=#{extra_libs}
    ]

    if build.with?("qt")
      qt = Formula["qt"]

      args << "--with-moc=#{qt.opt_bin}/moc"
      args << "--with-uic=#{qt.opt_bin}/uic"
      args << "--with-rcc=#{qt.opt_bin}/rcc"
      args << "--enable-qt"
    else
      args << "--disable-qt"
    end

    system "./autogen.sh" if build.head?

    system "./configure", *args

    system "rake", "-j#{ENV.make_jobs}"
    system "rake", "install"
  end

  test do
    mkv_path = testpath/"Great.Movie.mkv"
    sub_path = testpath/"subtitles.srt"
    sub_path.write <<~EOS
      1
      00:00:10,500 --> 00:00:13,000
      Homebrew
    EOS

    system "#{bin}/mkvmerge", "-o", mkv_path, sub_path
    system "#{bin}/mkvinfo", mkv_path
    system "#{bin}/mkvextract", "tracks", mkv_path, "0:#{sub_path}"
  end
end
