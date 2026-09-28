; Streamlity Windows kurulum betiği (Inno Setup 6).
; Release workflow'u derler:
;   iscc /DAppVersion=0.1.0 /DSourceDir=<Release klasörü> /DOutputDir=<çıktı> streamlity.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\build\installer"
#endif

[Setup]
; AppId değişmemeli; güncellemeler eski kurulumu bununla bulur.
AppId={{56EA4FDC-4D6A-4DA1-8A54-B7A29F12C5E2}
AppName=Streamlity
AppVersion={#AppVersion}
AppVerName=Streamlity {#AppVersion}
AppPublisher=Streamlity
AppPublisherURL=https://github.com/Efeyamann/Streamlity
AppSupportURL=https://github.com/Efeyamann/Streamlity/issues
AppUpdatesURL=https://github.com/Efeyamann/Streamlity/releases
DefaultDirName={autopf}\Streamlity
DefaultGroupName=Streamlity
DisableProgramGroupPage=yes
; Varsayılan kullanıcı başına kurulum (yönetici izni istemez); istenirse tüm kullanıcılar.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
LicenseFile=..\..\LICENSE
SetupIconFile=..\runner\resources\app_icon.ico
; Programlar listesinde sürümsüz ad; winget ve güncellemeler aynı adı görür.
UninstallDisplayName=Streamlity
UninstallDisplayIcon={app}\streamlity.exe
OutputDir={#OutputDir}
OutputBaseFilename=Streamlity-{#AppVersion}-windows-x64-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
; Uygulamanın 12 diliyle aynı. Inno Setup'la gelmeyen ya da yalnız yeni
; sürümlerinde gelen çeviriler languages\ altında (Inno Setup 6.7.1'den).
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "chinesesimplified"; MessagesFile: "languages\ChineseSimplified.isl"
Name: "hindi"; MessagesFile: "languages\Hindi.islu"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "arabic"; MessagesFile: "languages\Arabic.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "bengali"; MessagesFile: "languages\Bengali.islu"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "indonesian"; MessagesFile: "languages\Indonesian.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Streamlity"; Filename: "{app}\streamlity.exe"
Name: "{autodesktop}\Streamlity"; Filename: "{app}\streamlity.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\streamlity.exe"; Description: "{cm:LaunchProgram,Streamlity}"; Flags: nowait postinstall skipifsilent
