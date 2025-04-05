#!/bin/bash

echo "=== Axiom Trade Automation Linux Setup ==="
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

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo "Detected OS: $OS $VER"

# Install system dependencies based on distribution
step_header "Installing System Dependencies"
if command_exists apt-get; then
    # Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv wget curl
elif command_exists dnf; then
    # Fedora/RHEL
    sudo dnf update -y
    sudo dnf install -y python3 python3-pip python3-venv wget curl
elif command_exists pacman; then
    # Arch Linux
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm python python-pip python-virtualenv wget curl
else
    echo "Unsupported distribution. Please install the following manually:"
    echo "- Python 3"
    echo "- pip"
    echo "- virtualenv"
    echo "- wget"
    echo "- curl"
    exit 1
fi

# Install Google Chrome based on distribution
step_header "Installing Google Chrome"
if ! command_exists google-chrome; then
    echo "Installing Google Chrome..."
    if command_exists apt-get; then
        # Debian/Ubuntu
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
        sudo apt-get update
        sudo apt-get install -y google-chrome-stable
    elif command_exists dnf; then
        # Fedora/RHEL
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install -y google-chrome-stable
    elif command_exists pacman; then
        # Arch Linux
        sudo pacman -S --noconfirm google-chrome
    else
        echo "Please install Google Chrome manually from: https://www.google.com/chrome/"
    fi
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
        # Detect default Chrome profile path based on OS
        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            CHROME_PATH="$HOME/.config/google-chrome/Default"
        elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
            CHROME_PATH="$HOME/.config/google-chrome/Default"
        else
            CHROME_PATH="$HOME/.config/google-chrome/Default"
        fi
        
        cat > .env << EOL
# Phantom Wallet Configuration
PHANTOM_PASSWORD=your_password_here

# Chrome Profile Configuration
CHROME_PROFILE_PATH=$CHROME_PATH

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
chmod +x setup_linux.sh

step_header "Setup Complete"
echo "Next steps:"
echo "1. Edit the .env file with your settings:"
echo "   - Set your Phantom wallet password"
echo "   - Verify your Chrome profile path (typically in ~/.config/google-chrome/)"
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