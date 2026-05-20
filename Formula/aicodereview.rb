class Aicodereview < Formula
  desc "AI-agnostic code review skill pack for Claude Code, Codex, Cursor, Copilot, Gemini, and Aider"
  homepage "https://github.com/SUDARSHANCHAUDHARI/AICodeReview"
  url "https://github.com/SUDARSHANCHAUDHARI/AICodeReview/archive/refs/tags/v1.0.0.tar.gz"
  version "1.0.0"
  # sha256 "<fill after release>"
  license "MIT"

  depends_on "python3"

  def install
    bin.install "install.sh"   => "aicodereview-install"
    bin.install "uninstall.sh" => "aicodereview-uninstall"
    bin.install "update.sh"    => "aicodereview-update"
    bin.install "list-installed.sh" => "aicodereview-list"
    bin.install "check-health.sh"   => "aicodereview-health"
    prefix.install Dir["skills"]
    prefix.install Dir["templates"]
    prefix.install Dir["examples"]
  end

  def post_install
    ohai "AICodeReview installed."
    ohai "To install skills for Claude Code:"
    ohai "  aicodereview-install --agent claude"
    ohai ""
    ohai "To install for all agents (requires a project dir):"
    ohai "  aicodereview-install --agent all --project /path/to/project"
    ohai ""
    ohai "To check what is installed:"
    ohai "  aicodereview-list"
  end

  test do
    system "#{bin}/aicodereview-install", "--dry-run"
  end
end
