# Homebrew formula for Lumos — a calm, ambient macOS menu-bar app that shows
# Claude Code's 5-hour usage window as a notch glow + menu-bar LED.
#
# BUILD-FROM-SOURCE (not a cask): Homebrew compiles Lumos locally via Swift
# Package Manager. Because the binary is never downloaded prebuilt, macOS
# Gatekeeper never flags it — no "unidentified developer" prompt, no Apple
# Developer account, no notarization. See DISTRIBUTION.md in the main repo.
#
# Lives in the separate `homebrew-lumos` tap repo (`Yoge5h9/homebrew-lumos`).

class Lumos < Formula
  desc "Calm, ambient menu-bar glow for your Claude Code 5-hour usage window"
  homepage "https://github.com/Yoge5h9/Lumos"
  url "https://github.com/Yoge5h9/Lumos/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "87200eee39365255c4808ab50f32ac29dff74fa1bbf31c693c9bd3dd293f3c66"
  license "MIT"

  # `brew install --HEAD` builds straight off the default branch.
  head "https://github.com/Yoge5h9/Lumos.git", branch: "main"

  # No `depends_on xcode`: `swift build` is green on a Command-Line-Tools-only
  # machine, so requiring full Xcode (~15 GB) would be gratuitous. The light
  # install is a core selling point.
  depends_on macos: :ventura # LSMinimumSystemVersion == 13.0 (Ventura)

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    # Assemble the menu-bar .app the same way scripts/assemble-app.sh does, so
    # the brew install and local development produce an identical bundle.
    app_bundle = buildpath/"Lumos.app"
    contents   = app_bundle/"Contents"
    macos_dir  = contents/"MacOS"
    resources  = contents/"Resources"
    macos_dir.mkpath
    resources.mkpath

    cp buildpath/".build/release/lumos", macos_dir/"lumos"
    cp buildpath/"Resources/Info.plist", contents/"Info.plist"
    cp buildpath/"Resources/tips.json", resources/"tips.json"
    cp buildpath/"Resources/AppIcon.icns", resources/"AppIcon.icns"

    # Ad-hoc sign only (`-s -`) — deliberate: no Developer ID, no notarization.
    # This is what keeps the formula Gatekeeper-free.
    system "codesign", "-s", "-", "--force", "--deep", app_bundle

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
    assert_predicate prefix/"Lumos.app/Contents/Resources/AppIcon.icns", :exist?
  end
end
