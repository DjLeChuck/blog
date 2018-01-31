---
title: "Hugo - Créateur de sites statiques"
date: 2018-01-30T13:47:30+01:00
authors: ["djlechuck"]
tags: ["hugo"]
categories: ["veille-et-tests"]
toc: true
---

## Générateur de sites statiques ?
Les sites statiques sont des sites dont le contenu ne varie pas en fonction de
la demande du client. Cela signifie que tous les utilisateurs verront la même
chose s'afficher à l'écran, il n'y a pas de partie dynamique qui se
personnalise en fonction de critères.

Par exemple, un site de vente qui propose un espace client avec un catalogue et
un panier d'achat sera considéré comme un site dynamique car une partie des
pages qu'un utilisateur verra ne seront pas les mêmes que celles qu'un autre
verra à son tour. À l'inverse, ce site par exemple qui n'est composé que de
billets et pages satellites qui n'ont pas d'affichage dynamique en fonction de
qui les consultera (à l'exception du système de commentaires en bas de
page, mais c'est un outil proposé par un service externe qui n'entre pas dans
la conception du site).

Le but d'un générateur de sites statiques est donc de n'avoir qu'un
ensemble de fichiers HTML à envoyer sur son serveur accompagné des assets
nécessaires (CSS / JS / images / etc.).

Il existe une multitude d'outils permettant de réaliser ce genre de site comme
par exemple :

* [Hugo](https://gohugo.io/) - Celui dont on va parler ici !
* [Jekyll](https://jekyllrb.com/)
* [Hexo](https://hexo.io/)
* [Gatsby](https://www.gatsbyjs.org/)

[et pleins d'autres](https://www.staticgen.com/).

## Hugo comment ça marche ?

Hugo est un outil écrit en [Go](https://fr.wikipedia.org/wiki/Go_(langage)) qui
s'utilise depuis un terminal pour générer au final un site statique. Il se base
sur plusieurs choses :

* Des fichiers écrits en [Markdown](https://fr.wikipedia.org/wiki/Markdown)
pour le contenu des billets,
* des fichiers TOML, YAML ou JSON pour configurer certaines parties des billets / du
site,
* des fichiers de tout autre type (HTML, CSS, JS, etc.) pour gérer le thème
du site et ces assets.

**Tout ce que je vais décrire à partir de maintenant restera assez succint et
ne reflètera pas toute la puissance d'Hugo. La documentation du site est très
bien faîte et complète, il ne fau tpas hésiter à aller la voir aussi souvent
que possible !**

### Installation

Selon le système d'exploitation utilisé, l'installation est plus ou moins
simple comme on peut le voir [sur la page du site](https://gohugo.io/getting-started/installing).

Le plus simple reste encore de télécharger le binaire de la dernière version
disponible directement sur leur [GitHub](https://github.com/gohugoio/hugo/releases)
afin de garantir l'utilisation d'un outil à jour car les systèmes de paquet ne
proposent pas toujours une version à jour.

### Création d'un projet et structure de base

Pour instancier un projet, il suffit de lancer dans un terminal la commande
suivante :

```bash
hugo new site mon_blog
```

Cela va automatiquement créer l'arborescence de base du projet dans le dossier
indiqué (`mon_blog` dans cet exemple) :

```
mon_blog/
├── archetypes
│   └── default.md
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes

6 directories, 2 files
```

Voici un résumé du rôle de chaque répertoires / fichiers :

* [archetypes](https://gohugo.io/content-management/archetypes/#readout) :
les gabarits de pages que nous allons créer
* archetypes/default.md : le gabarit de base de toute les pages
* [config.toml]((https://gohugo.io/getting-started/configuration/#toml-configuration)) :
le fichier de configuration pincipal du site qui permettra de gérer tout un tas
de choses.
* [content](https://gohugo.io/content-management/organization/) : le contenu
du site, c'est-à-dire les différentes pages créées, les différentes ressources
les concernant, etc.
* [data](https://gohugo.io/templates/data-templates/#the-data-folder) : un
ensemble de fichiers permettant de gérer des données qui ne seront pas des
pages à proprement parler. Par exemple stocker les informations à propose de
l'auteur d'un billet et pouvoir le référencer ensuite dans une page sans avoir
besoin de dupliquer à chaque fois toutes les informations le concernant.
* [layouts](https://gohugo.io/themes/creating/#layouts) : permet de surcharger
le design établi par le thème du site.
* static : l'ensemble des fichiers statiques du site comme les images, les
fichiers JS / CSS, etc.
* [themes](https://gohugo.io/themes/) : l'ensemble des thèmes installés, même
si un seul sera actif à la fois via la configuration (le fichier `config.toml`).

Il existe beaucoup de thèmes créés par la communauté qui peuvent être installés
facilement. Cela permet de partir sur un design déjà existant et l'utiliser tel
quel ou bien de le modifier en le surchargeant grâce au dossier `layouts`.
La gallerie des thèmes [se trouve ici](https://themes.gohugo.io/) et les
explications sur comment en installer un
[sont là](https://gohugo.io/getting-started/quick-start/#step-3-add-a-theme).

### Ajouter une nouvelle page

#### Création du fichier

L'ajout d'une page peut se faire de deux façons :

* En utilisant une commande Hugo dans le terminal,
* en créant le fichier manuellement dans `content`.

La commande à utiliser est la suivante :

```bash
hugo new pages/ma-premiere-page.md
```

Cela va créer le fichier `ma-premiere-page.md` dans le dossier `content/pages`.
Si ce dernier n'existe pas (ce qui est le cas) alors Hugo va automatiquement le
créer pour nous.

L'avantage d'utiliser la commande Hugo vient de l'utilisation des `archetypes`,
les gabarits de fichiers cités précédemment. Si l'on regarde le contenu du
fichier généré on remarque qu'il n'est pas vide :

```yml
---
title: "Ma Premiere Page"
date: 2018-01-31T21:29:14+01:00
draft: true
---
```

Hugo s'est basé sur l'archetype qui correspondait au type de page que l'on
voulait créer. Par défaut il n'y a qu'un seul archetype et il est utilisé par
défaut si Hugo n'en détecte pas un plus adéquat.

Voici le contenu de l'archetype par défaut :

```yml
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
---
```

On voit que le `title` sera composé du nom du fichier auquel on remplacera les
tirets `-` par un espace et que la casse sera changée en titre (une majuscule à
chaque nouveau mot) ; La date sera automatiquement renseignée par celle de
l'exécution de la commande et un paramètre supplémentaire `draft: true` sera
ajouté tel quel.

Si on avait eu un archetype nommé `pages.md` dans le dossier correspondant,
Hugo l'aurait utilisé à la place du `default.md` afin de préparer la nouvelle
page pour nous.

#### Anatomie d'un fichier

Toute la première partie d'un fichier, ce qui se trouve entre les tirets `---`
s'appelle le [Front Matter](https://gohugo.io/content-management/front-matter/#readout).
Il s'agit de meta-données écrites par défaut en YAML (mais qui peuvent être
en TOML ou en JSON) qui seront analysées par Hugo et qui permettent de
définir plusieurs caractéristiques de la page comme par exemple sa date de
publication, son slug, sa catégorie, son titre, etc. Il existe un bon nombre
de données par défaut mais il est tout à fait possible d'en ajouter des
personnalisées afin d'en profiter ensuite dans le thème du site (il n'est
d'ailleurs pas rare que des thèmes en proposent également) !

Tout ce qui se trouvera ensuite sous le Front Matter constituera le corps de la
page, c'est-à-dire ce qui sera transformé en HTML puis affiché à l'écran de
l'utilisateur. Il est important de noter que même si le rendu final sera un
site statique, il existe tout un tas de systèmes qui permettent de dynamiser
le rendu des pages que fera Hugo au moment de leur transformation en HTML.
Ainsi, on peut utiliser les [shortcodes](https://gohugo.io/content-management/shortcodes/)
qui sont des fragments de code réutilisables dans nos pages pour faciliter des
rendus par exemple.

Par défaut, Hugo dispose déjà de [shortcodes](https://gohugo.io/content-management/shortcodes/#use-hugo-s-built-in-shortcodes)
mais on peut en créer autant qu'on le souhaite. Pour se faire, il suffit de
créer un nouveau fichier dans `layouts/shortcodes/monshortcode.html` et il sera
directement utilisable dans vos pages grâce à la syntaxe suivante
`{{</* monshortcode */>}}` (le nom de votre fichier = le nom de votre shortcode).

#### Visualisation du résultat

Afin de voir dans un navigateur le rendu de notre site, il suffit de lancer
un serveur grâce à la commande suivante :

```bash
hugo server -D
```

Cette commande possède tout un ensemble d'options (inclure ou non certains de
nos fichiers selon leur état, changer des répertoires etc.) qui sont définies
dans [la documentation](https://gohugo.io/commands/hugo_server/#readout).

La seule chose importante à noter ici est l'utilisation de l'option `-D` qui va
dire à Hugo d'inclure nos pages brouillons, c'est-à-dire qui possèdent un
paramètre `draft: true` dans leur Front Matter. Le serveur sera lancé et le
site accessible via l'URL http://127.0.0.1:1313/.

Par défaut Hugo est en mode `watch`, ce qui signifie que tout changement qui
intervient dans un des dossiers `content` ,`data`, `layouts` ou `static`
déclenchera une nouvelle compilation de code de sa part et la page se
rechargera automatiquement pour voir les changements apparaître.

### Préparer le site pour le publier en ligne

Une fois satisfait du rendu du site et que l'on est prêt à l'envoyer sur un
serveur, il faut demander à Hugo de générer le site statique via la commande
suivante :

```bash
hugo
```

Simple n'est-ce pas ? Hugo va interpréter le Markdown des pages crées, exécuter
les shortcodes etc. afin que toutes les pages soient transformées et fichiers
statiques HTML ou XML. Par défaut, tout le contenu sera généré dans un dossier
`public` et prêt à l'emploi ! Il suffira d'envoyer tout le contenu de ce
dossier sur un serveur et le site sera accessible et fonctionnel sans rien
faire d'autre.

## Conclusion

Il y a encore tant de choses à dire sur Hugo et ses capacités que je ferais
peut-être des posts plus spécialisés dans certaines parties de son
fonctionnement. Dans tous les cas, la documentation reste une alliée de taille
pour appréhender les différentes possibilitées de l'outil.

Je conseil également de regarder les vidéos
[YouTube](https://www.youtube.com/watch?v=qtIqKaDlqXo&list=PLLAZ4kZ9dFpOnyRlyS-liKL5ReHDcj4G3)
proposées par
[Giraffe Academy](http://www.giraffeacademy.com/) qui permettent de balayer
les grandes parties de la documentation. Les vidéos sont d'ailleurs présentes
dans certaines pages de la documentation officielle, gage de la qualité de leur
contenu.

![Pink Gopherize](/images/pink-gopherize.png)
