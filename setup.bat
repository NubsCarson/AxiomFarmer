@echo off
echo =====================================
echo Axiom Trade Automation Suite - Setup
echo =====================================
echo.

:: Environment validation
echo Validating environment...
python --version > nul 2>&1
if errorlevel 1 (
    echo Error: Python 3.8+ required
    echo Visit: https://www.python.org/downloads/
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

:: Virtual environment setup
if not exist venv\ (
    echo Initializing virtual environment...
    python -m venv venv
) else (
    echo Virtual environment detected...
)

:: Environment activation
echo Configuring environment...
call venv\Scripts\activate

:: Dependencies installation
echo Installing dependencies...
pip install -r requirements.txt > nul 2>&1
if errorlevel 1 (
    echo Error: Dependency installation failed
    echo Please check your network connection and try again
    pause > nul
    exit /b 1
)

:: Browser automation setup
echo Configuring browser automation...
playwright install > nul 2>&1
if errorlevel 1 (
    echo Error: Browser automation setup failed
    pause > nul
    exit /b 1
)

:: Profile configuration
if not exist chrome_profile\ (
    echo Creating session profile...
    mkdir chrome_profile > nul 2>&1
)

:: Environment configuration
if not exist .env (
    echo Generating environment configuration...
    copy .env.example .env > nul 2>&1
    echo Note: Update .env with your configuration before execution
)

echo.
echo =====================================
echo Setup completed successfully
echo.
echo Execution Instructions:
echo 1. Configure environment variables (.env)
echo 2. Execute: python src/main.py
echo.
echo For enterprise licensing:
echo - Discord: 1gig
echo - Email: [CEO@nubs.site]
echo =====================================
echo.
echo Press any key to exit...
pause > nul 