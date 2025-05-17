<div align="center">

# 🚀 fuzzyrabbit.sh Bash Helper 💣

<img src="Image_fx.jpg" alt="fuzzyrabbit.sh Banner" width="700"/>
<!-- You'll need to create a banner image and put it in an 'assets' folder -->

**Your Interactive Co-Pilot for FFUF Command Line Mastery!**

Tired of fumbling with `ffuf` syntax during intense CTFs or pentests?
fuzzyrabbit.sh Bash Helper is a colorful, interactive command-line script that guides you through building complex `ffuf` commands, ensuring you get your fuzzing right, *fast*.

![Bash Version](https://img.shields.io/badge/Bash-%3E%3D4.0-blue?style=for-the-badge&logo=gnu-bash)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
<!-- Optional: Add a CI/CD badge if you set one up -->

</div>

---

## ✨ Features

*   🎨 **Colorful & Interactive Interface:** Easy-to-follow prompts with ANSI colors.
*   💄 **Enhanced UI with `gum`:** If [gum](https://github.com/charmbracelet/gum) is installed, enjoy beautiful input fields and selection menus! Gracefully falls back if `gum` is not present.
*   🧭 **Guided Command Building:** Step-by-step process for constructing `ffuf` commands.
*   🎯 **Focus on CTF Essentials:** Quickly set up URLs, wordlists, HTTP methods, headers, extensions, status code filtering, and recursion.
*   💡 **Smart Defaults:** Sensible pre-filled values for common options to speed things up.
*   👁️ **Live-ish Command Preview:** See the command take shape as you answer prompts.
*   ✅ **Final Review & Execution:** Confirm the command before running it directly from the script.
*   📋 **Clipboard Integration:** Automatically tries to copy the final command to your clipboard (`xclip` or `pbcopy`).
*   🔧 **Configurable `ffuf` Path:** Easily point to your `ffuf` binary.
*   🚀 **Speed Up Your Workflow:** Spend less time on syntax and more time finding vulns!

---


---

## ⚙️ Requirements

*   **Bash:** Version 4.0 or higher.
*   **`ffuf`:** Must be installed and preferably in your `PATH`. [Get ffuf](https://github.com/ffuf/ffuf)
*   **(Optional but Recommended) `gum`:** For the enhanced UI. [Install gum](https://github.com/charmbracelet/gum#installation)
*   **(Optional for Clipboard) `xclip` or `pbcopy`:** For copying the command to the clipboard on Linux/macOS.

---

## 🚀 Installation & Usage

1.  **Clone the repository (or download `fuzzyrabbit.sh`):**
    ```bash
    git clone https://github.com/somerandomcell/FuzzyRabbit.git
    cd FuzzyRabbit
    ```
    
2.  **Make the script executable:**
    ```bash
    chmod +x fuzzyrabbit.sh
    ```

3.  **Run the script:**
    ```bash
    ./fuzzyrabbit.sh
    ```

4.  **Follow the interactive prompts!** The script will guide you through setting up:
    *   🎯 Target URL (with `FUZZ` keyword)
    *   📖 Wordlist
    *   📡 HTTP Method
    *   👤 Custom Headers
    *   📎 Extensions
    *   🚦 Status Code Matching/Filtering
    *   🔄 Recursion
    *   ...and more!

5.  **Review the generated command.**

6.  **Choose to execute it immediately or copy it to your clipboard.**

---

## 🛠️ Customization

*   **`FFUF_COMMAND` Variable:**
    At the top of `fuzzyrabbit.sh`, you can change the `FFUF_COMMAND` variable if your `ffuf` binary is not in your `PATH` or has a different name:
    ```bash
    FFUF_COMMAND="/path/to/your/ffuf"
    ```

---

## 🎨 Making it Your Own (The "Colorful" and "Well-Designed" Part)

This script uses ANSI escape codes for colors. Here's a peek at how it's done:

```bash
# Example color definitions in the script
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

# Usage example
echo -e "${CYAN}${BOLD}Enter Target URL:${NORMAL} ${YELLOW}[Default: http://localhost/FUZZ]${NORMAL}"
