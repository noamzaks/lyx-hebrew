@echo off

rem verify admin
net session >nul 2>&1 || (
    echo Please run this script with Administrator permissions.
)

:installCulmusLaTeX
echo Installing Culmus LaTeX fonts
echo Downloading...
powershell -Command "Invoke-WebRequest https://sourceforge.net/projects/ivritex/files/latest/download -OutFile culmuslatex.tar.gz"
7z x "culmuslatex.tar.gz" -so | 7z x -aoa -si -ttar -o"culmuslatex"

echo Copying fonts...
xcopy ./culmuslatex/usr/share/texmf/fonts C:\texlive\2020\texmf-dist
xcopy ./culmuslatex/usr/share/texmf/tex C:\texlive\2020\texmf-dist
mktexlsr
updmap-sys --enable Map=culmus.map
echo Culmus LaTeX installed
goto :eof

:postInstall
echo Copying keymap, preferences and default template
xcopy /y .\defaults.lyx %USERDIR%\AppData\Roaming\lyx-XXXX\templates\defaults.lyx
xcopy /y .\preferences %USERDIR%\AppData\Roaming\lyx-XXXX\preferences
xcopy /y .\cua.bind "C:\Program Files\LyX\bind\cua.bind"
echo Configuration files copied
goto :eof

echo Starting installation
choco version >nul 2>&1 && (
    echo Chocolatey detected! Using chocolatey to install: TeXLive Basic, LyX
    choco install texlive
    tlmgr install babel-hebrew
    mktexlsr
    updmap-sys
    call installCulmusLaTeX
    choco install lyx
    call postInstall
    echo Installation complete! Enjoy

    choice /M "Install Adobe Acrobat Reader with Chocolatey? Y/N: " && (
        choco install adobereader
    )
    echo You might need to reconfigure before LyX rendering works.
) || (
    echo Chocolatey not detected! Install everything from web?
    choice /M "Y/N: " && (
        echo Installing TeXLive Basic
        echo Downloading...
        powershell -Command "Invoke-WebRequest http://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe -OutFile installtexlive.exe"
        echo Starting installation
        .\installtexlive.exe -no-gui -scheme basic
        echo TeXLive installed
        
        call installCulmusLaTeX

        echo Installing LyX
        echo Downloading...
        powershell -Command "Invoke-WebRequest https://ftp.lip6.fr/pub/lyx/bin/2.3.6/LyX-236-Installer-2-x64.exe -OutFile installlyx.exe"
        .\installyx.exe /S
        call postInstall

        echo Installation complete! Enjoy
        echo You might need to reconfigure before LyX rendering works.
    ) || (
        echo Installation aborted.
    )
)
