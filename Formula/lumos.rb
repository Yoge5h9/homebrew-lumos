# Homebrew formula for Lumos — a calm, ambient macOS menu-bar app that shows
# Claude Code's 5-hour usage window as a notch glow + menu-bar LED.
#
# PREBUILT BINARY (not a cask): the stable install downloads a prebuilt,
# ad-hoc-signed universal Lumos.app from the GitHub Release — no compiler, no
# Command Line Tools, no Xcode. It stays Gatekeeper-free without an Apple
# Developer account because a Homebrew *formula* installs files WITHOUT the
# com.apple.quarantine xattr, and an ad-hoc signature is enough to run. (A cask
# would be quarantined and need notarization — this is a formula, not a cask.)
#
# `brew install --HEAD` still compiles from source for anyone who prefers it.
#
# Lives in the separate `homebrew-lumos` tap repo (`Yoge5h9/homebrew-lumos`).

class Lumos < Formula
  desc "Calm, ambient menu-bar glow for your Claude Code 5-hour usage window"
  homepage "https://github.com/Yoge5h9/Lumos"
  version "0.1.2"
  url "https://github.com/Yoge5h9/Lumos/releases/download/v0.1.2/Lumos-0.1.2-universal.tar.gz"
  sha256 "04dcd574ae319c9166a0122c4126370125c495137477605e419393765b6cf561"
  license "MIT"

  # `brew install --HEAD` builds straight off the default branch from source.
  head "https://github.com/Yoge5h9/Lumos.git", branch: "main"

  depends_on macos: :ventura # LSMinimumSystemVersion == 13.0 (Ventura)

  def install
    if build.head?
      # Source path (opt-in): compile + assemble the same bundle release.sh ships.
      system "swift", "build", "-c", "release", "--disable-sandbox"
      app_bundle = buildpath/"Lumos.app"
      contents   = app_bundle/"Contents"
      (contents/"MacOS").mkpath
      (contents/"Resources").mkpath
      cp buildpath/".build/release/lumos", contents/"MacOS/lumos"
      cp buildpath/"Resources/Info.plist", contents/"Info.plist"
      cp buildpath/"Resources/tips.json", contents/"Resources/tips.json"
      cp buildpath/"Resources/AppIcon.icns", contents/"Resources/AppIcon.icns"
      system "codesign", "-s", "-", "--force", "--deep", app_bundle
    end

    # Stable path: the release tarball already contains a signed, universal
    # Lumos.app at its root — nothing to build.
    prefix.install "Lumos.app"
    bin.install_symlink prefix/"Lumos.app/Contents/MacOS/lumos" => "lumos"
  end

  def caveats
    <<~EOS
      Lumos is installed but not yet wired up. Finish setup with:

        lumos setup

      This wires your Claude Code status line (non-destructively — your existing
      status line is backed up and wrapped, never replaced) so Lumos can read
      your 5-hour usage window locally. No network calls, no accounts, no API keys.

      To launch Lumos now:
        open #{opt_prefix}/Lumos.app

      To fully reverse setup later:
        lumos setup --uninstall
    EOS
  end

  test do
    assert_predicate prefix/"Lumos.app/Contents/MacOS/lumos", :exist?
    assert_predicate prefix/"Lumos.app/Contents/Info.plist", :exist?
  end
end
