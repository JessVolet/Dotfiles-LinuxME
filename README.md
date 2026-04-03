# LinuxME Dotfiles

Repositorio de dotfiles para SwayFX + Quickshell + Matugen.

## Estructura

- dotfiles/.config: configuraciones enlazables a ~/.config
- dotfiles/scripts: scripts de rice-manager y launcher
- dotfiles/themes: temas .theme
- install: instaladores y utilidades de export/deploy

## Flujo recomendado

1) Exportar tu estado actual de dotfiles al repo:

./install/export-current-dotfiles.sh

2) Instalar dependencias en Fedora:

./install/install-fedora.sh

3) Desplegar dotfiles en HOME (con backup automatico):

./install/deploy-dotfiles.sh

4) O hacer todo junto:

./bootstrap.sh
