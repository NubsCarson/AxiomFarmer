#!/bin/bash

echo "=== Axiom Trade Automation macOS Setup ==="
echo

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display step header
step_header() {
    echo
    echo "=== $1 ==="
    echo
}

# Check if running on macOS
if [[ $(uname) != "Darwin" ]]; then
    echo "This script is designed to run on macOS"
    echo "Please use setup_linux.sh for Linux or setup_wsl.sh for WSL"
    exit 1
fi

# Install Homebrew if not installed
step_header "Checking Homebrew Installation"
if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed"
fi

# Install system dependencies
step_header "Installing System Dependencies"
echo "Updating Homebrew..."
brew update

echo "Installing Python..."
brew install python@3.12

echo "Installing Google Chrome..."
if ! command_exists google-chrome; then
    brew install --cask google-chrome
else
    echo "Google Chrome is already installed"
fi

# Create and activate virtual environment
step_header "Setting up Python Virtual Environment"
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
else
    echo "Virtual environment already exists"
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install Python dependencies
step_header "Installing Python Dependencies"
pip install -r requirements.txt

# Install Playwright browsers
step_header "Installing Playwright Browsers"
playwright install chromium chrome

# Check if .env exists, if not copy from example
step_header "Checking Environment Configuration"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "Creating .env file from example..."
        cp .env.example .env
        echo "Please edit .env file with your settings"
    else
        echo "Creating .env file..."
        # Set macOS Chrome profile path
        CHROME_PATH="$HOME/Library/Application Support/Google/Chrome/Default"
        
        cat > .env << EOL
# Phantom Wallet Configuration
PHANTOM_PASSWORD=your_password_here

# Chrome Profile Configuration
CHROME_PROFILE_PATH="$CHROME_PATH"

# Axiom Configuration
AXIOM_URL=https://axiom.trade/@3gig
EOL
        echo "Please edit .env file with your settings"
    fi
fi

# Create necessary directories
step_header "Setting up Directory Structure"
mkdir -p logs

# Set executable permissions
chmod +x setup_mac.sh

step_header "Setup Complete"
echo "Next steps:"
echo "1. Edit the .env file with your settings:"
echo "   - Set your Phantom wallet password"
echo "   - Verify your Chrome profile path (typically in ~/Library/Application Support/Google/Chrome/Default)"
echo
echo "2. Run the Phantom setup script:"
echo "   python3 src/setup_phantom.py"
echo
echo "3. Once Phantom is set up, run the main script:"
echo "   python3 src/main.py"
echo
echo "Note: Make sure to have the Phantom wallet extension installed in Chrome"
echo "      and your Chrome profile properly configured."
echo

# Remind about virtual environment
echo "Remember to activate the virtual environment before running scripts:"
echo "source venv/bin/activate"
echo

# Additional macOS-specific notes
echo "macOS-specific notes:"
echo "- If you encounter permission issues, you may need to allow Chrome automation in System Preferences"
echo "- For Apple Silicon Macs (M1/M2), make sure Rosetta 2 is installed if needed"
echo "- If Chrome is not in Applications folder, the script may need adjustment"
echo

# End of script
exit 0 