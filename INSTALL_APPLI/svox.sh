#!/bin/sh
#######################################################################
# Author : Louis DAUBIGNARD
# Date   : 07/10/2015
#
# Description : Script pour :
#		- Installation application SVOX
#
# Syntax : [application].sh 
#
########################################################################
# Sources web :
#	http://forum.ubuntu-fr.org/viewtopic.php?id=108430
#	http://blog.erwan.me/post/2015/05/06/Synth%C3%A8se-vocale-sous-Ubuntu-avec-SVOX-pico-TTS
#	http://elinux.org/RPi_Text_to_Speech_%28Speech_Synthesis%29#Pico_Text_to_Speech
#	http://wiki.freeswitch.org/wiki/Mod_tts_commandline
########################################################################
#CHEMIN RACINE
PATHROOT="$PWD"
###########
clear
############################ Traduction ##############################
#
install_msg_fr() {
    msg_installer_welcome="*      Bienvenue dans l'assistant d'intallation/mise à jour de SVOX Pico       *"
	msg_installer_name="*      Installation SVOX Pico       *"
	msg_file_config="\033[31m[ERREUR]\033[0m Manque fichier de config"
	msg_ctrl_system="\033[35m[00]\035[0m Contrôle - Pre-requis"
	msg_install_multiverse="\033[35m[01]\035[0m Installation Dépôts multiverse"
	msg_install_dependency="\033[35m[02]\035[0m Mise à jour du système"
	msg_install_dependency="\033[35m[03]\035[0m Installation des dépendances"
	msg_install_test="\033[35m[FIN]\035[0m Test de l'application"
	
}
install_msg_en() {
    msg_installer_welcome="*      Welcome to SVOX Pico installer/updater        *"
	msg_installer_name="*      SVOX Pico Installer      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Control - Pre-requisite"
	msg_install_multiverse="\033[35m[01]\035[0m Installation Dépôts multiverse"
	msg_install_dependency="\033[35m[02]\035[0m Mise à jour du système"
	msg_install_dependency="\033[35m[03]\035[0m Installation des dépendances"
	msg_install_test="\033[35m[FIN]\035[0m Test de l'application"
}
install_msg_pt() {
    msg_installer_welcome="*      Bem-vindo ao assistente de instalação / atualização SVOX Pico        *"
	msg_installer_name="*      SVOX Pico instalação      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Controle - Pré-requisito"
	msg_install_multiverse="\033[35m[01]\035[0m Multiverse source install"
	msg_install_dependency="\033[35m[02]\035[0m System Update"
	msg_install_dependency="\033[35m[03]\035[0m Dependency install"
	msg_install_test="\033[35m[FIN]\035[0m Test"	
}
install_msg_de() {
    msg_installer_welcome="*       Willkommen beim SVOX Pico Installer / Updater       *"
	msg_installer_name="*      SVOX Pico Installer      *"
	msg_file_config="\033[31m[ERROR]\033[0m Config file is missing"
	msg_ctrl_system="\033[35m[00]\035[0m Steuerung - Erforderliche"
	msg_install_multiverse="\033[35m[01]\035[0m Multiverse source install"
	msg_install_dependency="\033[35m[02]\035[0m System Update"
	msg_install_dependency="\033[35m[03]\035[0m Dependency install"
	msg_install_test="\033[35m[FIN]\035[0m Test"
}
############################ Fonctions ##############################
#
setup_i18n() {
    lang=${LANG:=en_US}
    case ${lang} in
        [Ff][Rr]*)
            install_msg_fr
        ;;
        [Ee][Nn]*|*)
            install_msg_en
        ;;
		[Pt][Pt]*|*)
            install_msg_pt
        ;;
        [De][De]*|*)
            install_msg_de
        ;;
    esac
}
install_srcmultiverse() {
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty universe multiverse" | sudo tee /etc/apt/sources.list.d/multiverse.list
	echo "deb http://security.ubuntu.com/ubuntu trusty-security universe multiverse" 	>> /etc/apt/sources.list.d/multiverse.list
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse" 	>> /etc/apt/sources.list.d/multiverse.list
}
install_dependency() {
    apt-get update
    apt-get -y install
    apt-get -y install build-essential
    apt-get -y install curl
	apt-get -y install git-core 
	apt-get -y install automake 
	apt-get -y install autogen 
	apt-get -y install libtool 
	apt-get -y install libpopt-dev
	apt-get -y install xclip
	apt-get -y install alsa-utils
	apt-get -y install libttspico-utils
	apt-get -y install zenity
	apt-get -y install xsel

    apt-get autoremove
}
install_software() {
	cd /usr/src
	git clone git://git.debian.org/collab-maint/svox.git svox-git
	cd svox-git
	git branch -a
	git checkout -f origin/debian-sid
	cd pico
	base64 -d -i << EOF | patch -p2
ZGlmZiAtLWdpdCBhL3BpY28vbGliL3BpY29hcGkuYyBiL3BpY28vbGliL3BpY29hcGkuYwppbmRl
eCBiZTZkMWEyLi5kMDk5YmRhIDEwMDY0NAotLS0gYS9waWNvL2xpYi9waWNvYXBpLmMKKysrIGIv
cGljby9saWIvcGljb2FwaS5jCkBAIC00MSwxMCArNDEsMTAgQEAgZXh0ZXJuICJDIiB7CiAjZGVm
aW5lIE1BR0lDX01BU0sgMHg1MDY5NjM2RiAgLyogUGljbyAqLwogCiAjZGVmaW5lIFNFVF9NQUdJ
Q19OVU1CRVIoc3lzKSBcCi0gICAgKHN5cyktPm1hZ2ljID0gKChwaWNvb3NfdWludDMyKSAoc3lz
KSkgXiBNQUdJQ19NQVNLCisgICAgKHN5cyktPm1hZ2ljID0gKChwaWNvb3NfdWludHB0cl90KSAo
c3lzKSkgXiBNQUdJQ19NQVNLCiAKICNkZWZpbmUgQ0hFQ0tfTUFHSUNfTlVNQkVSKHN5cykgXAot
ICAgICgoc3lzKS0+bWFnaWMgPT0gKCgocGljb29zX3VpbnQzMikgKHN5cykpIF4gTUFHSUNfTUFT
SykpCisgICAgKChzeXMpLT5tYWdpYyA9PSAoKChwaWNvb3NfdWludHB0cl90KSAoc3lzKSkgXiBN
QUdJQ19NQVNLKSkKIAogCiAKZGlmZiAtLWdpdCBhL3BpY28vbGliL3BpY29hcGkuaCBiL3BpY28v
bGliL3BpY29hcGkuaAppbmRleCBhYTYwMzU4Li5hMGZkNWMzIDEwMDY0NAotLS0gYS9waWNvL2xp
Yi9waWNvYXBpLmgKKysrIGIvcGljby9saWIvcGljb2FwaS5oCkBAIC0xNzYsNyArMTc2LDYgQEAg
dHlwZWRlZiB1bnNpZ25lZCBpbnQgcGljb19VaW50MzI7CiAjZXJyb3IgInBsYXRmb3JtIG5vdCBz
dXBwb3J0ZWQiCiAjZW5kaWYKIAotCiAvKiBDaGFyIGRhdGEgdHlwZSAqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi8KIAogdHlwZWRlZiB1bnNpZ25l
ZCBjaGFyIHBpY29fQ2hhcjsKZGlmZiAtLWdpdCBhL3BpY28vbGliL3BpY29hcGlkLmggYi9waWNv
L2xpYi9waWNvYXBpZC5oCmluZGV4IGVmNjI3MDEuLmIzOGJjODYgMTAwNjQ0Ci0tLSBhL3BpY28v
bGliL3BpY29hcGlkLmgKKysrIGIvcGljby9saWIvcGljb2FwaWQuaApAQCAtNDgsNyArNDgsNyBA
QCBleHRlcm4gIkMiIHsKIAogLyogUGljbyBzeXN0ZW0gZGVzY3JpcHRvciAqLwogdHlwZWRlZiBz
dHJ1Y3QgcGljb19zeXN0ZW0gewotICAgIHBpY29vc191aW50MzIgbWFnaWM7ICAgICAgICAvKiBt
YWdpYyBudW1iZXIgdXNlZCB0byB2YWxpZGF0ZSBoYW5kbGVzICovCisgICAgcGljb29zX3VpbnRw
dHJfdCBtYWdpYzsgICAgICAgIC8qIG1hZ2ljIG51bWJlciB1c2VkIHRvIHZhbGlkYXRlIGhhbmRs
ZXMgKi8KICAgICBwaWNvb3NfQ29tbW9uIGNvbW1vbjsKICAgICBwaWNvcnNyY19SZXNvdXJjZU1h
bmFnZXIgcm07CiAgICAgcGljb2N0cmxfRW5naW5lIGVuZ2luZTsKZGlmZiAtLWdpdCBhL3BpY28v
bGliL3BpY29jdHJsLmMgYi9waWNvL2xpYi9waWNvY3RybC5jCmluZGV4IDNjNjU4MzEuLjRiMTk0
N2YgMTAwNjQ0Ci0tLSBhL3BpY28vbGliL3BpY29jdHJsLmMKKysrIGIvcGljby9saWIvcGljb2N0
cmwuYwpAQCAtNDk2LDcgKzQ5Niw3IEBAIHZvaWQgcGljb2N0cmxfZGlzcG9zZUNvbnRyb2wocGlj
b29zX01lbW9yeU1hbmFnZXIgbW0sCiAgKiAgc2hvcnRjdXQgICAgIDogZW5nCiAgKi8KIHR5cGVk
ZWYgc3RydWN0IHBpY29jdHJsX2VuZ2luZSB7Ci0gICAgcGljb29zX3VpbnQzMiBtYWdpYzsgICAg
ICAgIC8qIG1hZ2ljIG51bWJlciB1c2VkIHRvIHZhbGlkYXRlIGhhbmRsZXMgKi8KKyAgICBwaWNv
b3NfdWludHB0cl90IG1hZ2ljOyAgICAgICAgLyogbWFnaWMgbnVtYmVyIHVzZWQgdG8gdmFsaWRh
dGUgaGFuZGxlcyAqLwogICAgIHZvaWQgKnJhd19tZW07CiAgICAgcGljb29zX0NvbW1vbiBjb21t
b247CiAgICAgcGljb3JzcmNfVm9pY2Ugdm9pY2U7CkBAIC01MDgsMTAgKzUwOCwxMCBAQCB0eXBl
ZGVmIHN0cnVjdCBwaWNvY3RybF9lbmdpbmUgewogI2RlZmluZSBNQUdJQ19NQVNLIDB4NTA2OTQz
NkYgIC8qIFBpQ28gKi8KIAogI2RlZmluZSBTRVRfTUFHSUNfTlVNQkVSKGVuZykgXAotICAgIChl
bmcpLT5tYWdpYyA9ICgocGljb29zX3VpbnQzMikgKGVuZykpIF4gTUFHSUNfTUFTSworICAgIChl
bmcpLT5tYWdpYyA9ICgocGljb29zX3VpbnRwdHJfdCkgKGVuZykpIF4gTUFHSUNfTUFTSwogCiAj
ZGVmaW5lIENIRUNLX01BR0lDX05VTUJFUihlbmcpIFwKLSAgICAoKGVuZyktPm1hZ2ljID09ICgo
KHBpY29vc191aW50MzIpIChlbmcpKSBeIE1BR0lDX01BU0spKQorICAgICgoZW5nKS0+bWFnaWMg
PT0gKCgocGljb29zX3VpbnRwdHJfdCkgKGVuZykpIF4gTUFHSUNfTUFTSykpCiAKIC8qKgogICog
cGVyZm9ybXMgYW4gZW5naW5lIHJlc2V0CmRpZmYgLS1naXQgYS9waWNvL2xpYi9waWNvb3MuaCBi
L3BpY28vbGliL3BpY29vcy5oCmluZGV4IDg1OWUxNzYuLmZlNWFmYmEgMTAwNjQ0Ci0tLSBhL3Bp
Y28vbGliL3BpY29vcy5oCisrKyBiL3BpY28vbGliL3BpY29vcy5oCkBAIC03MCw2ICs3MCw4IEBA
IHR5cGVkZWYgcGljb3BhbF91aW50OCAgIHBpY29vc19ib29sOwogdHlwZWRlZiBwaWNvcGFsX29i
anNpemVfdCBwaWNvb3Nfb2Jqc2l6ZV90OwogdHlwZWRlZiBwaWNvcGFsX3B0cmRpZmZfdCBwaWNv
b3NfcHRyZGlmZl90OwogCit0eXBlZGVmIHBpY29wYWxfdWludHB0cl90IHBpY29vc191aW50cHRy
X3Q7CisKIC8qICoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KiovCiAvKiBmdW5jdGlvbnMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAq
LwogLyogKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi8K
ZGlmZiAtLWdpdCBhL3BpY28vbGliL3BpY29wYWwuaCBiL3BpY28vbGliL3BpY29wYWwuaAppbmRl
eCBhY2ZjOGUwLi4yZTY0NDI3IDEwMDY0NAotLS0gYS9waWNvL2xpYi9waWNvcGFsLmgKKysrIGIv
cGljby9saWIvcGljb3BhbC5oCkBAIC00MSw2ICs0MSw3IEBACiAjaW5jbHVkZSA8c3RkZGVmLmg+
CiAjaW5jbHVkZSAicGljb3BsdGYuaCIKICNpbmNsdWRlICJwaWNvZGVmcy5oIgorI2luY2x1ZGUg
PGludHR5cGVzLmg+CiAKICNpZmRlZiBfX2NwbHVzcGx1cwogZXh0ZXJuICJDIiB7CkBAIC0xMTcs
NiArMTE4LDcgQEAgdHlwZWRlZiB1bnNpZ25lZCBjaGFyICAgcGljb3BhbF91Y2hhcjsKIAogdHlw
ZWRlZiBzaXplX3QgICAgcGljb3BhbF9vYmpzaXplX3Q7CiB0eXBlZGVmIHB0cmRpZmZfdCBwaWNv
cGFsX3B0cmRpZmZfdDsKK3R5cGVkZWYgdWludHB0cl90IHBpY29wYWxfdWludHB0cl90OwogCiAv
KiAqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqLwogLyog
ZnVuY3Rpb25zICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKi8KZGlmZiAt
LWdpdCBhL3BpY28vbGliL3BpY29wci5jIGIvcGljby9saWIvcGljb3ByLmMKaW5kZXggMGQ2MTVk
OS4uYzAxY2ZkZSAxMDA2NDQKLS0tIGEvcGljby9saWIvcGljb3ByLmMKKysrIGIvcGljby9saWIv
cGljb3ByLmMKQEAgLTMyMDksMTEgKzMyMDksMTEgQEAgcGljb19zdGF0dXNfdCBwclJlc2V0KHJl
Z2lzdGVyIHBpY29kYXRhX1Byb2Nlc3NpbmdVbml0IHRoaXMsIHBpY29vc19pbnQzMiByZXNldE0K
ICAgICBwci0+YWN0Q3R4Q2hhbmdlZCA9IEZBTFNFOwogICAgIHByLT5wcm9kTGlzdCA9IE5VTEw7
CiAKLSAgICBpZiAoKChwaWNvb3NfdWludDMyKXByLT5wcl9Xb3JrTWVtICUgUElDT09TX0FMSUdO
X1NJWkUpID09IDApIHsKKyAgICBpZiAoKChwaWNvb3NfdWludHB0cl90KXByLT5wcl9Xb3JrTWVt
ICUgUElDT09TX0FMSUdOX1NJWkUpID09IDApIHsKICAgICAgICAgcHItPndvcmtNZW1Ub3AgPSAw
OwogICAgIH0KICAgICBlbHNlIHsKLSAgICAgICAgcHItPndvcmtNZW1Ub3AgPSBQSUNPT1NfQUxJ
R05fU0laRSAtICgocGljb29zX3VpbnQzMilwci0+cHJfV29ya01lbSAlIFBJQ09PU19BTElHTl9T
SVpFKTsKKyAgICAgICAgcHItPndvcmtNZW1Ub3AgPSBQSUNPT1NfQUxJR05fU0laRSAtICgocGlj
b29zX3VpbnRwdHJfdClwci0+cHJfV29ya01lbSAlIFBJQ09PU19BTElHTl9TSVpFKTsKICAgICB9
CiAgICAgcHItPm1heFdvcmtNZW1Ub3A9MDsKICAgICBwci0+ZHluTWVtU2l6ZT0wOwpkaWZmIC0t
Z2l0IGEvcGljby9saWIvcGljb3JzcmMuYyBiL3BpY28vbGliL3BpY29yc3JjLmMKaW5kZXggZDZl
MWU1MS4uNjgwYjgzOCAxMDA2NDQKLS0tIGEvcGljby9saWIvcGljb3JzcmMuYworKysgYi9waWNv
L2xpYi9waWNvcnNyYy5jCkBAIC01OCw3ICs1OCw3IEBAIGV4dGVybiAiQyIgewogICoKICAqLwog
dHlwZWRlZiBzdHJ1Y3QgcGljb3JzcmNfcmVzb3VyY2UgewotICAgIHBpY29vc191aW50MzIgbWFn
aWM7ICAvKiBtYWdpYyBudW1iZXIgdXNlZCB0byB2YWxpZGF0ZSBoYW5kbGVzICovCisgICAgcGlj
b29zX3VpbnRwdHJfdCBtYWdpYzsgIC8qIG1hZ2ljIG51bWJlciB1c2VkIHRvIHZhbGlkYXRlIGhh
bmRsZXMgKi8KICAgICAvKiBuZXh0IGNvbm5lY3RzIGFsbCBhY3RpdmUgcmVzb3VyY2VzIG9mIGEg
cmVzb3VyY2UgbWFuYWdlciBhbmQgdGhlIGdhcmJhZ2VkIHJlc291cmNlcyBvZiB0aGUgbWFuYWdl
cidzIGZyZWUgbGlzdCAqLwogICAgIHBpY29yc3JjX1Jlc291cmNlIG5leHQ7CiAgICAgcGljb3Jz
cmNfcmVzb3VyY2VfdHlwZV90IHR5cGU7CkBAIC03NSwxMCArNzUsMTAgQEAgdHlwZWRlZiBzdHJ1
Y3QgcGljb3JzcmNfcmVzb3VyY2UgewogI2RlZmluZSBNQUdJQ19NQVNLIDB4NzA0OTYzNEYgIC8q
IHBJY08gKi8KIAogI2RlZmluZSBTRVRfTUFHSUNfTlVNQkVSKHJlcykgXAotICAgIChyZXMpLT5t
YWdpYyA9ICgocGljb29zX3VpbnQzMikgKHJlcykpIF4gTUFHSUNfTUFTSworICAgIChyZXMpLT5t
YWdpYyA9ICgocGljb29zX3VpbnRwdHJfdCkgKHJlcykpIF4gTUFHSUNfTUFTSwogCiAjZGVmaW5l
IENIRUNLX01BR0lDX05VTUJFUihyZXMpIFwKLSAgICAoKHJlcyktPm1hZ2ljID09ICgoKHBpY29v
c191aW50MzIpIChyZXMpKSBeIE1BR0lDX01BU0spKQorICAgICgocmVzKS0+bWFnaWMgPT0gKCgo
cGljb29zX3VpbnRwdHJfdCkgKHJlcykpIF4gTUFHSUNfTUFTSykpCiAKIAogCkBAIC02MDMsNyAr
NjAzLDcgQEAgcGljb19zdGF0dXNfdCBwaWNvcnNyY19sb2FkUmVzb3VyY2UocGljb3JzcmNfUmVz
b3VyY2VNYW5hZ2VyIHRoaXMsCiAgICAgICAgICAgICBzdGF0dXMgPSAoTlVMTCA9PSByZXMtPnJh
d19tZW0pID8gUElDT19FWENfT1VUX09GX01FTSA6IFBJQ09fT0s7CiAgICAgICAgIH0KICAgICAg
ICAgaWYgKFBJQ09fT0sgPT0gc3RhdHVzKSB7Ci0gICAgICAgICAgICByZW0gPSAocGljb29zX3Vp
bnQzMikgcmVzLT5yYXdfbWVtICUgUElDT09TX0FMSUdOX1NJWkU7CisgICAgICAgICAgICByZW0g
PSAocGljb29zX3VpbnRwdHJfdCkgcmVzLT5yYXdfbWVtICUgUElDT09TX0FMSUdOX1NJWkU7CiAg
ICAgICAgICAgICBpZiAocmVtID4gMCkgewogICAgICAgICAgICAgICAgIHJlcy0+c3RhcnQgPSBy
ZXMtPnJhd19tZW0gKyAoUElDT09TX0FMSUdOX1NJWkUgLSByZW0pOwogICAgICAgICAgICAgfSBl
bHNlIHsK
EOF
	./autogen.sh
	./configure --prefix=/opt/svox-pico/
	make install
}
test_software() {
	#Télécharger et lancer le script:
	wget http://liveusb.info/xclip-speech/svox_pico.sh
	chmod +x svox_pico.sh
	./svox_pico.sh
	pico2wave -l fr-FR -w test.wav "le même test avec la voix feminine .f r de M brola et espeak"
	aplay test.wav
}
########################## Main Point entree ############################
# DEBUT ENTREE
setup_i18n
############################ Lib Fonctions ##############################
#
. "$PATHROOT/../lib/functions.sh"
printMessageTo  "             ${msg_installer_name}			" "1" 

########################## Fic Configuration ############################
#
checkPathFile "$PATHROOT/../config/config.sh" "Fichier de config"
if [ $? -eq 0 ];then
	echo -e "${msg_file_config}"
	exit 1
fi
. "$PATHROOT/../config/config.sh"
#CHECK DES LOGS
checkPathDst "$PATHDEST_REPLOG" "Chemin LOG"
##################################################################################################################
# TEST PRE-REQUIS
# Vérifier que l'utilisateur est root
printMessageTo  "             CONTROLE APPLI			" "3" 
checkUserRoot
# Vérifier que perl est installé pour la gestion des mots de passe
checkAppli perl
##################################################################################################################
# DEBUT PROCESS
printMessageTo  "    ${msg_installer_name}	 " "3" 
printMessageTo  "    ${msg_install_multiverse}	 " "2" 
install_srcmultiverse
printMessageTo  "    ${msg_install_dependency}	 " "2"
install_dependency
printMessageTo  "    ${msg_install_test}	 " "2" 
test_software



