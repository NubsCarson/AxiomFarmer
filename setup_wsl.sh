#!/bin/bash

echo "=== Axiom Trade Automation WSL Setup ==="
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

# Check if running in WSL
if ! grep -q Microsoft /proc/version; then
    echo "This script is designed to run in Windows Subsystem for Linux (WSL)"
    echo "Please run this in a WSL environment"
    exit 1
fi

# Install system dependencies
step_header "Installing System Dependencies"
sudo apt update
sudo apt install -y python3 python3-pip python3-venv wget curl

# Install Google Chrome
step_header "Installing Google Chrome"
if ! command_exists google-chrome; then
    echo "Installing Google Chrome..."
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
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
        cat > .env << EOL
# Phantom Wallet Configuration
PHANTOM_PASSWORD=your_password_here

# Chrome Profile Configuration
CHROME_PROFILE_PATH=/mnt/c/Users/${USER}/AppData/Local/Google/Chrome/User Data/Default

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
chmod +x setup_wsl.sh

step_header "Setup Complete"
echo "Next steps:"
echo "1. Edit the .env file with your settings:"
echo "   - Set your Phantom wallet password"
echo "   - Verify your Chrome profile path"
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

# End of script
exit 0 