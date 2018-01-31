---
title: "Hugo - Créateur de sites statiques"
date: 2018-01-30T13:47:30+01:00
authors: ["djlechuck"]
tags: ["hugo"]
categories: ["veille-et-tests"]
toc: true
draft: true
---

## Générateur de sites statiques ?
Les sites statiques sont des sites dont le contenu ne varie pas en fonction de la demande du client.
Cela signifie que tous les utilisateurs verront la même chose s'afficher à l'écran, il n'y a pas de
partie dynamique qui se personnalise en fonction de critères.

Par exemple, un site de vente qui propose un espace client avec un catalogue et un panier d'achat
sera considéré comme un site dynamique car une partie des pages qu'un utilisateur verra ne seront
pas les mêmes que celles qu'un autre verra à son tour. À l'inverse, ce site par exemple qui n'est
composé que de billets et pages satellites qui n'ont pas d'affichage dynamique en fonction de qui
les consultera (à l'exception du système de commentaires en bas de page, mais c'est un outil
proposé par un service externe qui n'entre pas dans la conception du site).

Le but d'un site générateur de sites statiques est donc de n'avoir qu'un ensemble de fichiers HTML
à envoyer sur son serveur accompagné des assets nécessaires (CSS / JS / images / etc.).

Il existe une multitude d'outils permettant de réaliser ce genre de site comme par exemple :

* [Hugo](https://gohugo.io/) - Celui dont on va parler ici !
* [Jekyll](https://jekyllrb.com/)
* [Hexo](https://hexo.io/)
* [Gatsby](https://www.gatsbyjs.org/)

[et pleins d'autres](https://www.staticgen.com/).

## Hugo comment ça marche ?

Hugo se base sur plusieurs choses :

* Des fichiers écrits en [Markdown](https://fr.wikipedia.org/wiki/Markdown) pour le contenu des
billets,
* des fichiers TOML, YAML ou JSON pour configurer certaines parties,
* des fichiers de tout autre type (HTML, CSS, JS, etc.) pour gérer le thème du site et ces assets.
