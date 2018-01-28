---
title: "Express + Flux + React"
date: 2017-01-24T16:26:59+01:00
authors: ["djlechuck"]
tags: ["express", "flux", "react"]
categories: ["veille-et-tests"]
---

## Avant-propos

Nous avons besoin de mettre en place une stack de développement pérenne qui
permette de réaliser des sites dynamiques, fluides et rapides. Deux pré-requis
étaient de pouvoir utiliser des API REST en tant que fournisseurs de données et
d’utiliser React {{< ref "https://facebook.github.io/react/" >}} en tant que
moteur de vue (+ utiliser l’architecture de Flux
{{< ref "https://facebook.github.io/flux/" >}} et son flux de données
unidirectionnel).

La question a alors été de choisir le langage de programmation qui serait
utilisé pour la partie back-office. Ce choix a été porté sur NodeJS et a donc
amené au second questionnement : quel framework utiliser ?

Étant le seul développeur, mon choix s’est porté sur Express
{{< ref "http://expressjs.com/" >}} qui est un des frameworks NodeJS les plus
connus. Il existe tout un tas de modules prêts à l’emploi qui offres de
nouvelles fonctionnalités à ses capacités de base.

Pour ce qui est de la partie front, comme indiqué précédemment, il faut
utiliser React.

## HOWTO

### Installer le projet Express

Pour commencer, utilisons le fichier **package.json** suivant :

```json
{
  "name": "express-server",
  "version": "0.0.1",
  "private": true,
  "babel": {
    "presets": [
      "es2015",
      "stage-0"
   ]
  },
  "scripts": {
    "server": "babel-node server.js"
  }
}
```

Installons ensuite les dépendances du serveur, à savoir Express en lui-même :

```bash
npm install --save express
```

Puis nous installons Babel {{< ref "https://babeljs.io/" >}} qui est un outils
permettant entre autre de compiler le code JavaScript ES2015 en code
compréhensible par les navigateurs qui ne supportent pas encore ces nouveautés
ou encore de transformer les fichiers JSX de React en fichiers JS :

```bash
npm install --save-dev babel-cli babel-core babel-preset-es2015 babel-preset-stage-0
```

Enfin, nous avons le fichier **server.js** qui sera le point d’entrée du
backend :

```js
import express from 'express';

const app = express();

app.set('port', (process.env.PORT || 3001));

// express only serves static assets in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static('client/build'));
}

// api routes and others
app.get('/hello', (req, res) => {
  res.json(['Hello world!']);
});

// handles all routes so you do not get a not found error
app.get('/*', function (req, res){
  res.sendFile('client/build/index.html', { root: __dirname })
});

// start the server
app.listen(app.get('port'),  (err) => {
  if (err) {
    return console.error(err);
  }

  console.log(`Find the server at: http://localhost:${app.get('port')}/`); // eslint-disable-line no-console
});
```

### Installer React + Flux

Un outil appelé create-react-app
{{< ref "https://github.com/facebookincubator/create-react-app" >}}
permet de mettre en place rapidement un gabarit de front utilisant React. C’est
un outil fourni par Facebook qui est activement maintenu par la communauté et
est en constante évolution.

Commençons par l’installer globalement dans Node :

```bash
npm install -g create-react-app
```

Ensuite, nous allons pouvoir l’utiliser pour générer notre template de front
au sein de notre projet :

```bash
create-react-app client
```

Ceci va ajouter un dossier **/client** à notre projet qui contiendra tout le
front du site en React. Ce dossier étant un projet à part entière (qui pourrait
être en dehors de notre projet serveur) il possède ses propres dépendances qui
auront déjà été installées par l’outil.

Nous en profitons pour installer Reflux
{{< ref "https://github.com/reflux/refluxjs" >}} (librairie implémentant le
principe de Flux) :

```bash
cd client && npm install --save reflux && cd ..
```

## Faire cohabiter back et front

Nous avons d’un côté notre backend avec Express et de l’autre notre frontend
avec React (et Webpack {{< ref "https://webpack.github.io/docs/" >}}
_under the hood_). Au lieu de lancer séparément les deux processus dans
deux consoles différentes nous utiliserons Concurrently
{{< ref "https://github.com/kimmobrunfeldt/concurrently/" >}} qui permet de
faire cela mieux que nous en utilisant une seule console.

Actuellement, la dernière version 3.1.0 n’est pas fonctionnelle avec mon
Windows 10 et l’utilisation de GitBash. J’ai donc utilisé la version 2.2.0
afin de ne pas avoir de problème :

```bash
npm install --save-dev concurrently@2.2.0
```

Nous allons maintenant créer un fichier **start-client.js** qui servira à
lancer de manière transparente, quelque soit l’OS utilisé, notre front :

```js
const args = [ 'start' ];
const opts = { stdio: 'inherit', cwd: 'client', shell: true };
require('child_process').spawn('npm', args, opts);
```

Nous n’appellerons pas directement ce fichier. À la place, nous allons ajouter
deux entrées de scripts dans notre **package.json** en plus de celle déjà
présente :

```js
"scripts": {
    "start": "concurrently \"npm run server\" \"npm run client\"",
    "server": "babel-node server.js", // Already here
    "client": "babel-node start-client.js"
},
```

Ceci nous permet maintenant soit de lancer le back via

```bash
npm run server
```

, soit de lancer le front via

```bash
npm run client
```

soit de lancer les deux en même temps via

```bash
npm start
```

Le dernier point à configurer concerne la communication entre le mini-serveur
lancé par Webpack sur le front et notre serveur Express ; Le but étant que les
requêtes HTTP effectuées sur le front soient renvoyées sur le back afin d’y
être traitées.

Pour cela, rien de plus simple grâce à react-script
{{< ref "https://github.com/facebookincubator/create-react-app/tree/master/packages/react-scripts" >}}
(qui fait parti de create-react-app). Il nous suffit d’éditer le fichier
**/client/package.json** et d’y ajouter la ligne suivante :

```js
"proxy": "http://localhost:3001/",
```

## Conclusion

Et voilà ! Tout est prêt pour commencer à créer son projet en utilisant Express
et React. Le code de notre serveur et celui de notre client sont indépendants
(hormis la configuration du proxy ajoutée en dernier lieu) ce qui permettrait
par exemple d’héberger tout le front sur un serveur différent de celui du back.
