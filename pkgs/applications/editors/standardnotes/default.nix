{ stdenv, appimageTools, autoPatchelfHook, desktop-file-utils
  , fetchurl, runtimeShell }:

let
  version = "3.5.6";
  pname = "standardnotes";
  name = "${pname}-${version}";

  plat = {
    i386-linux = "-linux-i386";
    x86_64-linux = "-linux-x86_64";
  }.${stdenv.hostPlatform.system};

  sha256 = {
    i386-linux = "60d68cd0047d03c6752a2f20b8c2b5c9f536b14c0978b79f16ebb8bbf07817c9";
    x86_64-linux = "6d9bbafa1a57b061b9b9cf77af818e863c43799bbc06f4355e81a535a215209c";
  }.${stdenv.hostPlatform.system};

  src = fetchurl {
    url = "https://github.com/standardnotes/desktop/releases/download/v${version}/standard-notes-${version}${plat}.AppImage";
    inherit sha256;
  };

  appimageContents = appimageTools.extract {
    inherit name src;
  };

  nativeBuildInputs = [ autoPatchelfHook desktop-file-utils ];

in appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    # directory in /nix/store so readonly
    cp -r  ${appimageContents}/* $out
    cd $out
    chmod -R +w $out
    mv $out/bin/${name} $out/bin/${pname}

    # fixup and install desktop file
    ${desktop-file-utils}/bin/desktop-file-install --dir $out/share/applications \
      --set-key Exec --set-value ${pname} standard-notes.desktop

    rm usr/lib/* AppRun standard-notes.desktop .so*
  '';

  meta = with stdenv.lib; {
    description = "A simple and private notes app";
    longDescription = ''
      Standard Notes is a private notes app that features unmatched simplicity,
      end-to-end encryption, powerful extensions, and open-source applications.
    '';
    homepage = "https://standardnotes.org";
    license = licenses.agpl3;
    maintainers = with maintainers; [ mgregoire ];
    platforms = [ "i386-linux" "x86_64-linux" ];
  };
}
