# Aliase dauerhaft unter Debian 13 setzen

## Benutzer-Alias dauerhaft speichern

1.  `.bashrc` öffnen:

``` bash
nano ~/.bashrc
```

2.  Alias am Ende der Datei hinzufügen:

``` bash
alias ll='ls -alF'
alias update='sudo apt update && sudo apt upgrade'
```

3.  Änderungen laden:

``` bash
source ~/.bashrc
```

Alternativ einfach ein neues Terminal öffnen.

------------------------------------------------------------------------

## Alias systemweit (für alle Benutzer)

Datei öffnen:

``` bash
sudo nano /etc/bash.bashrc
```

Alias hinzufügen:

``` bash
alias ll='ls -alF'
```

------------------------------------------------------------------------

## Funktion testen

``` bash
alias
```

oder

``` bash
ll
```

------------------------------------------------------------------------

## Optional: Eigene Alias-Datei

Datei erstellen:

``` bash
nano ~/.bash_aliases
```

Beispiel:

``` bash
alias gs='git status'
alias gc='git commit'
```

In `.bashrc` sicherstellen:

``` bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```
